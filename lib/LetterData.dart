import 'package:flutter/material.dart';
import 'TracingPoint.dart'; // Create this file with the TracingPoint class

class LetterData {
  static Map<String, List<TracingPoint>> urduLetters = {
    "ا": [
      TracingPoint(Offset(150, 15)),
      TracingPoint(Offset(150, 80)),
      TracingPoint(Offset(150, 100)),
      TracingPoint(Offset(150, 120)),
      TracingPoint(Offset(150, 140)),
      TracingPoint(Offset(150, 160)),
      TracingPoint(Offset(150, 220)),
      TracingPoint(Offset(150, 240)),
    ],
    "ب": [
      TracingPoint(Offset(290, 80)),
      TracingPoint(Offset(299, 110)),
      TracingPoint(Offset(310, 145)),
      TracingPoint(Offset(285, 170)),
      // TracingPoint(Offset(257, 179)),
      TracingPoint(Offset(239, 186)),
      TracingPoint(Offset(205, 187)),
      // TracingPoint(Offset(170, 180)),
      TracingPoint(Offset(155, 182)),
      TracingPoint(Offset(130, 162)),
      TracingPoint(Offset(128, 133)),
      TracingPoint(Offset(180, 170), isNukta: true),
    ],
  };
}
