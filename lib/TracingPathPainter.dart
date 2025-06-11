import 'package:flutter/material.dart';

class TracingPathPainter extends CustomPainter {
  final List<Offset> path;

  TracingPathPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final tracePath = Path();
    tracePath.moveTo(path[0].dx, path[0].dy);

    for (int i = 1; i < path.length - 1; i++) {
      // Use the midpoint between current and next point for smooth curves
      Offset midPoint = (path[i] + path[i + 1]) / 2;
      tracePath.quadraticBezierTo(
        path[i].dx,
        path[i].dy,
        midPoint.dx,
        midPoint.dy,
      );
    }

    // Draw final segment to last point
    tracePath.lineTo(path.last.dx, path.last.dy);

    canvas.drawPath(tracePath, paint);
  }

  @override
  bool shouldRepaint(covariant TracingPathPainter oldDelegate) {
    return oldDelegate.path != path;
  }
}
