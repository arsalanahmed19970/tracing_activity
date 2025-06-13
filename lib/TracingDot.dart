import 'package:flutter/material.dart';

class TracingDot extends StatelessWidget {
  final Offset position;
  final bool isNukta;
  const TracingDot({required this.position, this.isNukta = false, super.key});
  

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - (isNukta ? 8 : 5),
      top: position.dy - (isNukta ? 8 : 5),
      child: isNukta
          ? CustomPaint(size: const Size(16, 16), painter: RhombusPainter())
          : Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
    );
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
