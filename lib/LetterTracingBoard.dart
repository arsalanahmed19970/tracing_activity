import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tracing_activity/LetterData.dart';
import 'package:tracing_activity/PathAreaPainter.dart';
import 'package:tracing_activity/TracingBubble.dart';
import 'package:tracing_activity/TracingDot.dart';
import 'package:tracing_activity/TracingPathPainter.dart';
import 'package:tracing_activity/TracingPoint.dart';

class LetterTracingBoard extends StatefulWidget {
  final String letter;
  final VoidCallback onCompleted;
  final bool isCompleted;

  const LetterTracingBoard({
    required this.letter,
    required this.onCompleted,
    required this.isCompleted,
    super.key,
  });

  @override
  State<LetterTracingBoard> createState() => _LetterTracingBoardState();
}

class _LetterTracingBoardState extends State<LetterTracingBoard>
    with SingleTickerProviderStateMixin {
  late List<TracingPoint> originalDotPositions;
  late List<TracingPoint> dotPositions;

  List<Offset> tracedPath = [];
  int currentDotIndex = 0;
  bool isTracingComplete = false;
  final double maxDeviationThreshold = 90.0;

  late AnimationController _controller;
  bool isPausedDueToDeviation = false;
  bool isPausedByUser = false;
  bool isDragging = false;
  Offset? dragStartPosition;
  final double minDragDistance = 15.0;

  Size? currentScreenSize;

  @override
  void initState() {
    super.initState();
    originalDotPositions = LetterData.urduLetters[widget.letter] ?? [];
    dotPositions = List.from(originalDotPositions);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 90),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void centerLetter(Size screenSize) {
    if (originalDotPositions.isEmpty) return;

    double minX = originalDotPositions
        .map((e) => e.position.dx)
        .reduce((a, b) => a < b ? a : b);
    double maxX = originalDotPositions
        .map((e) => e.position.dx)
        .reduce((a, b) => a > b ? a : b);
    double minY = originalDotPositions
        .map((e) => e.position.dy)
        .reduce((a, b) => a < b ? a : b);
    double maxY = originalDotPositions
        .map((e) => e.position.dy)
        .reduce((a, b) => a > b ? a : b);

    Offset letterCenter = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    Offset screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    Offset offsetToCenter = screenCenter - letterCenter;

    // Store the previous offset to calculate the difference
    Offset? previousOffset;
    if (dotPositions.isNotEmpty) {
      // Calculate previous offset by comparing first dot positions
      Offset previousFirstDot = dotPositions[0].position;
      Offset originalFirstDot = originalDotPositions[0].position;
      previousOffset = previousFirstDot - originalFirstDot;
    }

    // Update dot positions with new offset
    dotPositions = originalDotPositions
        .map(
          (p) => TracingPoint(p.position + offsetToCenter, isNukta: p.isNukta),
        )
        .toList();

    // Update tracedPath if there was a previous offset (screen rotation occurred)
    if (previousOffset != null && tracedPath.isNotEmpty) {
      Offset offsetDifference = offsetToCenter - previousOffset;
      tracedPath = tracedPath.map((point) => point + offsetDifference).toList();
    }
  }

  List<Offset> getCenteredPathAreaOffsets() {
    if (originalDotPositions.isEmpty) return [];

    // Calculate the same offset that was applied to the dots
    double minX = originalDotPositions
        .map((e) => e.position.dx)
        .reduce((a, b) => a < b ? a : b);
    double maxX = originalDotPositions
        .map((e) => e.position.dx)
        .reduce((a, b) => a > b ? a : b);
    double minY = originalDotPositions
        .map((e) => e.position.dy)
        .reduce((a, b) => a < b ? a : b);
    double maxY = originalDotPositions
        .map((e) => e.position.dy)
        .reduce((a, b) => a > b ? a : b);

    Offset letterCenter = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    Offset screenCenter = Offset(
      currentScreenSize?.width ?? 400,
      currentScreenSize?.height ?? 600,
    );
    Offset offsetToCenter = screenCenter - letterCenter;

    // Apply the same offset to path area offsets
    final originalPathAreaOffsets =
        LetterData.pathAreaOffsets[widget.letter] ?? [];
    return originalPathAreaOffsets
        .map((offset) => offset + offsetToCenter)
        .toList();
  }

  void resetTracing() {
    setState(() {
      tracedPath.clear();
      currentDotIndex = 0;
      isTracingComplete = false;
      isDragging = false; // Reset dragging state
      dragStartPosition = null; // Clear drag start position
      stopNuktaBlinking();
    });
  }

  bool isLastNonNuktaPoint() {
    for (int i = currentDotIndex + 1; i < dotPositions.length; i++) {
      if (!dotPositions[i].isNukta) return false;
    }
    return true;
  }

  void startNuktaBlinking() {
    _controller.repeat(reverse: true);
  }

  void stopNuktaBlinking() {
    _controller.stop();
  }

  bool isTooFarFromPath(Offset currentPosition) {
    if (currentDotIndex >= dotPositions.length) return false;
    final targetPoint = dotPositions[currentDotIndex].position;
    final distance = (currentPosition - targetPoint).distance;
    return distance > maxDeviationThreshold;
  }

  Offset get currentPosition => currentDotIndex < dotPositions.length
      ? dotPositions[currentDotIndex].position
      : dotPositions.last.position;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Size newScreenSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Check if screen size has changed (rotation occurred)
        bool screenSizeChanged =
            currentScreenSize != null &&
            (currentScreenSize!.width != newScreenSize.width ||
                currentScreenSize!.height != newScreenSize.height);

        // Update current screen size
        currentScreenSize = newScreenSize;

        // Center the letter (this will also update tracedPath if screen rotated)
        centerLetter(newScreenSize);

        final pointerPos = currentPosition;

        return GestureDetector(
          onPanStart: (details) {
            // Store the initial position
            dragStartPosition = details.localPosition;

            if (currentDotIndex == 0) {
              final startPoint = dotPositions[0].position;
              final distance = (details.localPosition - startPoint).distance;
              if (distance < 25) {
                setState(() {
                  tracedPath.add(startPoint);
                  isTracingComplete = false;
                  stopNuktaBlinking();
                  isPausedDueToDeviation = false;
                  isDragging = false; // Start with not dragging
                });
              }
            } else {
              final currentTarget = dotPositions[currentDotIndex].position;
              final distance = (details.localPosition - currentTarget).distance;
              if (distance < 25) {
                setState(() {
                  isPausedDueToDeviation = false;
                  isDragging = false; // Start with not dragging
                });
              }
            }
          },
          onPanEnd: (_) {
            setState(() {
              isDragging = false; // Stop dragging
              dragStartPosition = null; // Clear start position
            });
            if (!isPausedDueToDeviation && !isLastNonNuktaPoint()) {
              setState(() {
                isPausedByUser = true;
              });
            }
          },
          onPanCancel: () {
            setState(() {
              isDragging = false; // Stop dragging
              dragStartPosition = null; // Clear start position
            });
            if (!isPausedDueToDeviation && !isLastNonNuktaPoint()) {
              setState(() {
                isPausedByUser = true;
              });
            }
          },
          onPanUpdate: (details) {
            if (currentDotIndex >= dotPositions.length ||
                isPausedDueToDeviation)
              return;

            // Check if user has moved enough to be considered dragging
            if (!isDragging && dragStartPosition != null) {
              final distanceMoved =
                  (details.localPosition - dragStartPosition!).distance;
              if (distanceMoved >= minDragDistance) {
                setState(() {
                  isDragging = true;
                });
              }
            }

            if (isTooFarFromPath(details.localPosition)) {
              setState(() {
                isPausedDueToDeviation = true;
              });
              return;
            }

            final newPos = details.localPosition;
            if (isCloseToNextDot(newPos) && isDragging) {
              // Only advance if dragging
              final currentPoint = dotPositions[currentDotIndex];
              if (!currentPoint.isNukta) {
                setState(() {
                  tracedPath.add(currentPoint.position);
                });
              }

              if (isLastNonNuktaPoint()) {
                setState(() {
                  isTracingComplete = true;
                  startNuktaBlinking();
                });
                widget.onCompleted();
              } else if (!currentPoint.isNukta) {
                currentDotIndex++;
              }
            }
          },
          child: Stack(
            children: [
              // Path area for guidance using specific offsets
              CustomPaint(
                painter: PathAreaPainter(
                  dotPositions,
                  getCenteredPathAreaOffsets(),
                  pathWidth: 30.0,
                  currentDotIndex: currentDotIndex,
                  showCompletedPath: true,
                  animationValue: 0.0, // No animation for now
                ),
                size: Size.infinite,
              ),
              ...dotPositions
                  .where((tp) => !tp.isNukta)
                  .map(
                    (tp) => TracingDot(position: tp.position, isNukta: false),
                  ),
              if (isTracingComplete)
                ...dotPositions
                    .where((tp) => tp.isNukta)
                    .map(
                      (tp) => Positioned(
                        left: tp.position.dx - 8,
                        top: tp.position.dy - 8,
                        child: FadeTransition(
                          opacity: _controller,
                          child: CustomPaint(
                            size: const Size(16, 16),
                            painter: RhombusPainter(),
                          ),
                        ),
                      ),
                    ),
              CustomPaint(
                painter: TracingPathPainter(tracedPath),
                size: Size.infinite,
              ),
              if (currentDotIndex < dotPositions.length &&
                  !dotPositions[currentDotIndex].isNukta)
                TracingBubble(
                  position: pointerPos,
                  direction: calculateDirection(),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(LetterTracingBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.letter != widget.letter) {
      setState(() {
        originalDotPositions = LetterData.urduLetters[widget.letter] ?? [];
        tracedPath.clear();
        currentDotIndex = 0;
        isTracingComplete = false;
        isDragging = false; // Reset dragging state
        dragStartPosition = null; // Clear drag start position
        _controller.stop();
      });
    }
  }

  bool isCloseToNextDot(Offset position) {
    if (currentDotIndex >= dotPositions.length) return false;
    final currentPoint = dotPositions[currentDotIndex];
    double threshold = currentPoint.isNukta ? 15 : 25;
    return (position - currentPoint.position).distance < threshold;
  }

  double calculateDirection() {
    if (currentDotIndex >= dotPositions.length - 1) {
      // If we're at the last dot, use the direction from the previous dot
      if (currentDotIndex > 0) {
        final current = dotPositions[currentDotIndex].position;
        final previous = dotPositions[currentDotIndex - 1].position;
        final direction = (current - previous).direction;
        // Convert from x-axis based angle to rotation for upward-pointing arrow
        return direction + (pi / 2); // Add 90 degrees to align with arrow
      }
      return pi; // Default downward direction for arrow_upward icon
    }

    // Calculate direction from current dot to next dot
    final current = dotPositions[currentDotIndex].position;
    final next = dotPositions[currentDotIndex + 1].position;
    final direction = (next - current).direction;
    // Convert from x-axis based angle to rotation for upward-pointing arrow
    return direction + (pi / 2); // Add 90 degrees to align with arrow
  }
}

class RhombusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;

    // Create rhombus shape
    path.moveTo(centerX, centerY - halfHeight); // Top point
    path.lineTo(centerX + halfWidth, centerY); // Right point
    path.lineTo(centerX, centerY + halfHeight); // Bottom point
    path.lineTo(centerX - halfWidth, centerY); // Left point
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
