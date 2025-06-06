import 'package:flutter/material.dart';
import 'package:tracing_activity/DraggablePointer.dart';
import 'package:tracing_activity/LetterData.dart';
import 'package:tracing_activity/LetterOutlinePainter.dart';
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

  @override
  void initState() {
    super.initState();
    originalDotPositions = LetterData.urduLetters[widget.letter] ?? [];
    dotPositions = List.from(originalDotPositions);
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

    dotPositions = originalDotPositions
        .map(
          (p) => TracingPoint(p.position + offsetToCenter, isNukta: p.isNukta),
        )
        .toList();
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
        centerLetter(Size(constraints.maxWidth, constraints.maxHeight));
        final pointerPos = currentPosition;

        return GestureDetector(
          onPanStart: (details) {
            if (currentDotIndex == 0) {
              final startPoint = dotPositions[0].position;
              final distance = (details.localPosition - startPoint).distance;
              if (distance < 25) {
                setState(() {
                  tracedPath.add(startPoint);
                  isTracingComplete = false;
                  stopNuktaBlinking();
                  isPausedDueToDeviation = false;
                });
              }
            } else {
              final currentTarget = dotPositions[currentDotIndex].position;
              final distance = (details.localPosition - currentTarget).distance;
              if (distance < 25) {
                setState(() {
                  isPausedDueToDeviation = false;
                });
              }
            }
          },
          onPanEnd: (_) {
            if (!isPausedDueToDeviation && !isLastNonNuktaPoint()) {
              setState(() {
                isPausedByUser = true;
              });
            }
          },
          onPanCancel: () {
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

            if (isTooFarFromPath(details.localPosition)) {
              setState(() {
                isPausedDueToDeviation = true;
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
              CustomPaint(
                painter: LetterOutlinePainter(widget.letter),
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
                painter: TracingPathPainter(tracedPath),
                size: Size.infinite,
              ),
              if (currentDotIndex < dotPositions.length &&
                  !dotPositions[currentDotIndex].isNukta)
                DraggablePointer(position: pointerPos),
              if (currentDotIndex < dotPositions.length &&
                  !dotPositions[currentDotIndex].isNukta)
                TracingBubble(position: pointerPos),
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
}
