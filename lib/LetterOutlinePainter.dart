import 'package:flutter/material.dart';

class LetterOutlinePainter extends CustomPainter {
  final String letter;

  LetterOutlinePainter(this.letter);

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontSize: 300, // adjust size depending on screen
      color: Colors.black.withOpacity(0.1), // faint outline
      fontFamily: 'YourUrduFont', // optional: if needed for Urdu accuracy
    );

    final textSpan = TextSpan(text: letter, style: textStyle);

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
