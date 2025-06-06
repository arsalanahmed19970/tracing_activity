import 'package:flutter/material.dart';

class TracingDot extends StatelessWidget {
  final Offset position;
  final bool isNukta;
  const TracingDot({required this.position, this.isNukta = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 5,
      top: position.dy - 5,
      child: Container(
        width: isNukta ? 2 : 10,
        height: isNukta ? 2 : 10,
        decoration: BoxDecoration(
          color: isNukta ? Colors.red : Colors.black,
          shape: isNukta ? BoxShape.rectangle : BoxShape.circle,
        ),
      ),
    );
  }
}
