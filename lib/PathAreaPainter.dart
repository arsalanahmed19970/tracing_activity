import 'package:flutter/material.dart';
import 'TracingPoint.dart';

class PathAreaPainter extends CustomPainter {
  final List<TracingPoint> dotPositions;
  final List<Offset> pathAreaOffsets;
  final double pathWidth;
  final int currentDotIndex;
  final bool showCompletedPath;
  final double animationValue;

  PathAreaPainter(
    this.dotPositions,
    this.pathAreaOffsets, {
    this.pathWidth = 10.0,
    this.currentDotIndex = 0,
    this.showCompletedPath = true,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dotPositions.length < 2) return;

    // Get non-nukta dots
    final nonNuktaDots = dotPositions.where((tp) => !tp.isNukta).toList();
    if (nonNuktaDots.length < 2) return;

    // Create a simple path that follows the dots in sequence
    final allPathPoints = _createSimplePath(nonNuktaDots, pathAreaOffsets);

    // Draw completed path area (if enabled)
    if (showCompletedPath && currentDotIndex > 0) {
      final completedPoints = _getCompletedPathPoints(
        allPathPoints,
        currentDotIndex,
        nonNuktaDots,
      );
      _drawPathArea(
        canvas,
        completedPoints,
        const Color.fromARGB(255, 201, 225, 202).withOpacity(0.15),
        const Color.fromARGB(255, 235, 245, 235).withOpacity(0.4),
      );
    }

    // Draw remaining path area
    if (currentDotIndex < nonNuktaDots.length - 1) {
      final remainingPoints = _getRemainingPathPoints(
        allPathPoints,
        currentDotIndex,
        nonNuktaDots,
      );

      // Create pulsing effect for current segment
      final pulseOpacity = 0.1 + (0.1 * (0.5 + 0.5 * animationValue));
      final borderOpacity = 0.3 + (0.2 * (0.5 + 0.5 * animationValue));

      _drawPathArea(
        canvas,
        remainingPoints,
        Colors.blue.withOpacity(pulseOpacity),
        const Color.fromARGB(255, 15, 18, 20).withOpacity(borderOpacity),
      );
    }
  }

  List<Offset> _createSimplePath(
    List<TracingPoint> dots,
    List<Offset> pathOffsets,
  ) {
    final pathPoints = <Offset>[];

    // Add all dots in sequence
    for (final dot in dots) {
      pathPoints.add(dot.position);
    }

    // Add path area offsets in the right positions
    for (final pathOffset in pathOffsets) {
      // Find the best position to insert this offset
      int insertIndex = _findBestInsertPosition(pathOffset, dots);
      if (insertIndex >= 0 && insertIndex < pathPoints.length) {
        pathPoints.insert(insertIndex, pathOffset);
      }
    }

    return pathPoints;
  }

  int _findBestInsertPosition(Offset pathOffset, List<TracingPoint> dots) {
    if (dots.length < 2) return -1;

    // Find which two dots this offset is between
    for (int i = 0; i < dots.length - 1; i++) {
      final dot1 = dots[i].position;
      final dot2 = dots[i + 1].position;

      // Check if pathOffset is between these two dots
      if (_isBetweenPoints(pathOffset, dot1, dot2)) {
        return i + 1; // Insert after the first dot
      }
    }

    return -1; // Not between any dots
  }

  bool _isBetweenPoints(Offset point, Offset start, Offset end) {
    // Check if point is roughly between start and end points
    final distanceToStart = (point - start).distance;
    final distanceToEnd = (point - end).distance;
    final totalDistance = (end - start).distance;

    // Point is between if it's closer to both start and end than they are to each other
    return distanceToStart + distanceToEnd <= totalDistance * 1.5;
  }

  double _distanceFromStart(Offset point, Offset start) {
    return (point - start).distance;
  }

  List<Offset> _getCompletedPathPoints(
    List<Offset> allPoints,
    int currentDotIndex,
    List<TracingPoint> dots,
  ) {
    if (currentDotIndex <= 0) return [];

    final completedPoints = <Offset>[];
    final currentDot = dots[currentDotIndex].position;

    for (final point in allPoints) {
      if (_distanceFromStart(point, dots[0].position) <=
          _distanceFromStart(currentDot, dots[0].position)) {
        completedPoints.add(point);
      }
    }

    return completedPoints;
  }

  List<Offset> _getRemainingPathPoints(
    List<Offset> allPoints,
    int currentDotIndex,
    List<TracingPoint> dots,
  ) {
    if (currentDotIndex >= dots.length - 1) return [];

    final remainingPoints = <Offset>[];
    final currentDot = dots[currentDotIndex].position;

    for (final point in allPoints) {
      if (_distanceFromStart(point, dots[0].position) >=
          _distanceFromStart(currentDot, dots[0].position)) {
        remainingPoints.add(point);
      }
    }

    return remainingPoints;
  }

  void _drawPathArea(
    Canvas canvas,
    List<Offset> points,
    Color fillColor,
    Color borderColor,
  ) {
    if (points.length < 2) return;

    // Create a path that connects all the points with smooth curves (like TracingPathPainter)
    final path = Path();

    // Start at the first point
    path.moveTo(points[0].dx, points[0].dy);

    if (points.length == 2) {
      // Simple line for just 2 points
      path.lineTo(points[1].dx, points[1].dy);
    } else {
      // Create smooth curves between points (same as TracingPathPainter)
      for (int i = 1; i < points.length - 1; i++) {
        // Use the midpoint between current and next point for smooth curves
        Offset midPoint = (points[i] + points[i + 1]) / 2;
        path.quadraticBezierTo(
          points[i].dx,
          points[i].dy,
          midPoint.dx,
          midPoint.dy,
        );
      }

      // Draw final segment to last point
      if (points.length > 2) {
        path.lineTo(points.last.dx, points.last.dy);
      }
    }

    // Create paint for the path area
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = pathWidth
      ..strokeCap = StrokeCap.round;

    // Draw the path area
    canvas.drawPath(path, paint);

    // Draw a border around the path area
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant PathAreaPainter oldDelegate) {
    return oldDelegate.dotPositions != dotPositions ||
        oldDelegate.pathAreaOffsets != pathAreaOffsets ||
        oldDelegate.pathWidth != pathWidth ||
        oldDelegate.currentDotIndex != currentDotIndex ||
        oldDelegate.showCompletedPath != showCompletedPath ||
        oldDelegate.animationValue != animationValue;
  }
}
