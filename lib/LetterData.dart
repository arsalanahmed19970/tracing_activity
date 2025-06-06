import 'package:flutter/material.dart';
import 'TracingPoint.dart'; // Create this file with the TracingPoint class

class LetterData {
  static Map<String, List<TracingPoint>> urduLetters = {
    "ا": [
      TracingPoint(Offset(150, 100)),
      TracingPoint(Offset(150, 120)),
      TracingPoint(Offset(150, 140)),
      TracingPoint(Offset(150, 160)),
      TracingPoint(Offset(150, 180)),
      TracingPoint(Offset(150, 200)),
    ],
    "ب": [
      TracingPoint(Offset(250, 100)),
      TracingPoint(Offset(250, 120)),
      TracingPoint(Offset(250, 140)),
      TracingPoint(Offset(220, 140)),
      TracingPoint(Offset(200, 140)),
      TracingPoint(Offset(180, 140)),
      TracingPoint(Offset(150, 140)),
      TracingPoint(Offset(150, 120)),
      TracingPoint(Offset(150, 100)),
      TracingPoint(Offset(200, 180), isNukta: true),
    ],
  };
}
