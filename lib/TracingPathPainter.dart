import 'package:flutter/material.dart';

class TracingPathPainter extends CustomPainter {
  final List<Offset> path;

  TracingPathPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 1) return;

    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 25
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < path.length - 1; i++) {
      canvas.drawLine(path[i], path[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant TracingPathPainter oldDelegate) {
    return oldDelegate.path != path;
  }
}
