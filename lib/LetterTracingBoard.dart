import 'package:flutter/material.dart';
import 'package:tracing_activity/DraggablePointer.dart';
import 'package:tracing_activity/LetterData.dart';
import 'package:tracing_activity/TracingBubble.dart';
import 'package:tracing_activity/TracingDot.dart';
import 'package:tracing_activity/TracingPathPainter.dart';
import 'package:tracing_activity/TracingPoint.dart'; // <-- import this

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
  late List<TracingPoint> dotPositions;
  List<Offset> tracedPath = [];
  int currentDotIndex = 0;
  bool isTracingComplete = false;
  final double maxDeviationThreshold =
      80.0; // Maximum allowed deviation from path

  late AnimationController _controller;
  bool isPausedDueToDeviation = false;
  bool isPausedByUser = false;

  @override
  void initState() {
    super.initState();
    dotPositions = LetterData.urduLetters[widget.letter] ?? [];
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Rect calculateBoundingBox(List<TracingPoint> points) {
    double minX = points.first.position.dx;
    double minY = points.first.position.dy;
    double maxX = points.first.position.dx;
    double maxY = points.first.position.dy;

    for (var point in points) {
      minX = point.position.dx < minX ? point.position.dx : minX;
      minY = point.position.dy < minY ? point.position.dy : minY;
      maxX = point.position.dx > maxX ? point.position.dx : maxX;
      maxY = point.position.dy > maxY ? point.position.dy : maxY;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  void resetTracing() {
    setState(() {
      tracedPath.clear();
      currentDotIndex = 0;
      isTracingComplete = false;
      stopNuktaBlinking();
    });
  }

  bool isLastNonNuktaPoint() {
    // Check if next points are only nukta points
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
    if (currentDotIndex > (dotPositions.length)) return false;

    // Get the next target point
    final targetPoint = dotPositions[currentDotIndex].position;

    // Calculate distance from current position to target
    final distance = (currentPosition - targetPoint).distance;

    // If we're too far from the target point, return true
    return distance > maxDeviationThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final pointerPos = currentPosition;
    final screenSize = MediaQuery.of(context).size;
    final boundingBox = calculateBoundingBox(dotPositions);
    final double dx =
        (screenSize.width / 2) - (boundingBox.left + boundingBox.width / 2);
    final double dy =
        (screenSize.height / 2) - (boundingBox.top + boundingBox.height / 2);
    final Offset centerOffset = Offset(dx, dy);

    return GestureDetector(
      onPanStart: (details) {
        // Only start if we're close to the first dot
        if (currentDotIndex == 0) {
          final startPoint = dotPositions[0].position;
          final distance =
              (details.localPosition - startPoint + centerOffset).distance;
          if (distance < 25) {
            setState(() {
              tracedPath.add(startPoint + centerOffset);
              isTracingComplete = false;
              stopNuktaBlinking();
              isPausedDueToDeviation = false;
            });
          }
        } else {
          // Resume from pause if user touches near the current point again
          final currentTarget = dotPositions[currentDotIndex].position;
          final distance = (details.localPosition - currentTarget).distance;
          if (distance < 25) {
            setState(() {
              isPausedDueToDeviation = false;
            });
          }
        }
      },
      onPanEnd: (details) {
        // Only reset if we haven't reached the last non-nukta dot
        if (!isPausedDueToDeviation && !isLastNonNuktaPoint()) {
          // resetTracing();
          setState(() {
            isPausedByUser = true;
          });
        }
      },
      onPanCancel: () {
        // Only reset if we haven't reached the last non-nukta dot
        if (!isPausedDueToDeviation && !isLastNonNuktaPoint()) {
          // resetTracing();
          setState(() {
            isPausedByUser = true;
          });
        }
      },
      onPanUpdate: (details) {
        if (currentDotIndex >= dotPositions.length || isPausedDueToDeviation)
          return;

        // Check if we've deviated too far from the path
        if (isTooFarFromPath(details.localPosition)) {
          setState(() {
            isPausedDueToDeviation = true; // Pause tracking
          });
          return;
        }

        final newPos = details.localPosition;
        if (isCloseToNextDot(newPos)) {
          final currentPoint = dotPositions[currentDotIndex];
          if (!currentPoint.isNukta) {
            setState(() {
              tracedPath.add(currentPoint.position);
            });
          }

          if (isLastNonNuktaPoint()) {
            // If we've reached the last non-nukta point, complete the tracing
            setState(() {
              isTracingComplete = true;
              startNuktaBlinking();
            });
            widget.onCompleted();
          } else if (!dotPositions[currentDotIndex].isNukta) {
            // Only increment if current point is not a nukta
            currentDotIndex++;
          }
        }
      },
      child: Stack(
        children: [
          // First render non-nukta points
          ...dotPositions
              .where((tp) => !tp.isNukta)
              .map(
                (tp) => TracingDot(
                  position: tp.position + centerOffset,
                  isNukta: false,
                ),
              ),
          // Then render nukta points only if tracing is complete
          if (isTracingComplete)
            ...dotPositions
                .where((tp) => tp.isNukta)
                .map(
                  (tp) => Positioned(
                    left: tp.position.dx - 5,
                    top: tp.position.dy - 5,
                    child: FadeTransition(
                      opacity: _controller,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
          CustomPaint(
            painter: TracingPathPainter(
              tracedPath.map((p) => p + centerOffset).toList(),
            ),

            size: Size.infinite,
          ),
          if (currentDotIndex < dotPositions.length &&
              !dotPositions[currentDotIndex].isNukta)
            DraggablePointer(position: pointerPos + centerOffset),
          if (currentDotIndex < dotPositions.length &&
              !dotPositions[currentDotIndex].isNukta)
            TracingBubble(position: pointerPos + centerOffset),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(LetterTracingBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.letter != widget.letter) {
      setState(() {
        dotPositions = LetterData.urduLetters[widget.letter] ?? [];
        tracedPath.clear();
        currentDotIndex = 0;
        isTracingComplete = false;
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

  Offset get currentPosition => currentDotIndex < dotPositions.length
      ? dotPositions[currentDotIndex].position
      : dotPositions.last.position;
}
