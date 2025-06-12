import 'package:flutter/material.dart';
import 'TracingPoint.dart'; // Create this file with the TracingPoint class

class LetterData {
  static Map<String, List<TracingPoint>> urduLetters = {
    "ا": [
      TracingPoint(Offset(150, 30)),
      TracingPoint(Offset(150, 50)),
      TracingPoint(Offset(150, 65)),
      TracingPoint(Offset(150, 90)),
      TracingPoint(Offset(150, 110)),
      TracingPoint(Offset(150, 130)),
      TracingPoint(Offset(150, 150)),
      TracingPoint(Offset(150, 190)),
      TracingPoint(Offset(150, 205)),
      TracingPoint(Offset(150, 230)),
    ],
    "ب": [
      TracingPoint(Offset(290, 85)),
      TracingPoint(Offset(299, 120)),
      TracingPoint(Offset(310, 145)),
      TracingPoint(Offset(285, 170)),
      // TracingPoint(Offset(257, 179)),
      TracingPoint(Offset(239, 186)),
      TracingPoint(Offset(205, 187)),
      // TracingPoint(Offset(170, 180)),
      TracingPoint(Offset(155, 182)),
      TracingPoint(Offset(130, 162)),
      TracingPoint(Offset(128, 133)),
      TracingPoint(Offset(230, 230), isNukta: true),
    ],
  };

  // PathArea offsets for smoother path rendering
  static Map<String, List<Offset>> pathAreaOffsets = {
    "ا": [
      // Additional intermediate points between main dots for smoother path
      Offset(150, 40), // Between 30 and 50
      Offset(150, 57), // Between 50 and 65
      Offset(150, 77), // Between 65 and 90
      Offset(150, 100), // Between 90 and 110
      Offset(150, 120), // Between 110 and 130
      Offset(150, 140), // Between 130 and 150
      Offset(150, 170), // Between 150 and 190
      Offset(150, 197), // Between 190 and 205
      Offset(150, 217), // Between 205 and 230
    ],
    "ب": [
      // Additional intermediate points for Bay letter curve
      Offset(294, 102), // Between 290,85 and 299,120
      Offset(304, 132), // Between 299,120 and 310,145
      Offset(297, 157), // Between 310,145 and 285,170
      Offset(262, 178), // Between 285,170 and 239,186
      Offset(222, 186), // Between 239,186 and 205,187
      Offset(180, 184), // Between 205,187 and 155,182
      Offset(142, 172), // Between 155,182 and 130,162
      Offset(129, 147), // Between 130,162 and 128,133
      // Additional curve points for smoother shape
      Offset(140, 140), // Additional curve point
      Offset(180, 110), // Additional curve point
      Offset(220, 100), // Additional curve point
      Offset(260, 95), // Additional curve point
    ],
  };
}
