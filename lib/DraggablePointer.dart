import 'package:flutter/material.dart';

class DraggablePointer extends StatelessWidget {
  final Offset position;

  const DraggablePointer({required this.position, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 20,
      top: position.dy - 20,
      child: Container(
        // width: 40,
        // height: 40,
        // decoration: const BoxDecoration(
        //   color: Colors.blue,
        //   shape: BoxShape.circle,
        // ),
        child: const Icon(Icons.touch_app, color: Colors.white),
      ),
    );
  }
}
