import 'package:flutter/material.dart';

class TracingBubble extends StatelessWidget {
  final Offset position;
  final double direction;

  const TracingBubble({
    super.key,
    required this.position,
    this.direction = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 50,
      top: position.dy - 50,
      child: Transform.rotate(
        angle: direction,
        child: Container(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                color: Colors.transparent,
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.lightBlueAccent,
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
