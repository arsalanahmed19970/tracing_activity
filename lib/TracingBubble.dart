import 'package:flutter/material.dart';

class TracingBubble extends StatelessWidget {
  final Offset position;

  const TracingBubble({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 20, // adjust to center the bubble
      top: position.dy - 20,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.lightBlueAccent,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
      ),
    );
  }
}
