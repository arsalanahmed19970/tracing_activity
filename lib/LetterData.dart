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
      TracingPoint(Offset(250, 80)),
      TracingPoint(Offset(250, 100)),
      TracingPoint(Offset(250, 120)),
      TracingPoint(Offset(230, 140)),
      TracingPoint(Offset(200, 140)),
      TracingPoint(Offset(180, 140)),
      TracingPoint(Offset(160, 140)),
      TracingPoint(Offset(140, 140)),
      TracingPoint(Offset(120, 120)),
      TracingPoint(Offset(120, 100)),
      TracingPoint(Offset(120, 80)),
      TracingPoint(Offset(180, 170), isNukta: true),
    ],
  };
}
