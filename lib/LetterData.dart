import 'package:flutter/material.dart';
import 'TracingPoint.dart'; // Create this file with the TracingPoint class

class LetterData {
  static Map<String, List<TracingPoint>> urduLetters = {
    "ا": [
      TracingPoint(Offset(150, 30)),
      TracingPoint(Offset(150, 60)),
      TracingPoint(Offset(150, 90)),
      TracingPoint(Offset(150, 120)),
      TracingPoint(Offset(150, 150)),
      TracingPoint(Offset(150, 180)),
      TracingPoint(Offset(150, 210)),
      TracingPoint(Offset(150, 240)),
      TracingPoint(Offset(150, 270)),
      TracingPoint(Offset(150, 300)),
    ],
    "ب": [
      TracingPoint(Offset(290, 85)),
      TracingPoint(Offset(300, 120)),
      TracingPoint(Offset(299, 145)),
      TracingPoint(Offset(285, 170)),
      TracingPoint(Offset(260, 179)),
      TracingPoint(Offset(235, 179)),
      TracingPoint(Offset(205, 179)),
      TracingPoint(Offset(180, 179)),
      TracingPoint(Offset(155, 172)),
      TracingPoint(Offset(130, 160)),
      TracingPoint(Offset(128, 133)),
      TracingPoint(Offset(230, 230), isNukta: true),
    ],
  };

  // PathArea offsets for smoother path rendering
  static Map<String, List<Offset>> pathAreaOffsets = {
    "ا": [
      Offset(150, 40),
      Offset(150, 57),
      Offset(150, 77),
      Offset(150, 100),
      Offset(150, 120),
      Offset(150, 140),
      Offset(150, 170),
      Offset(150, 197),
      Offset(150, 217),
    ],
    "ب": [
      // Additional intermediate points for Bay letter curve
      Offset(294, 102),
      Offset(304, 132),
      Offset(297, 157),
      Offset(262, 178),
      Offset(222, 186),
      Offset(180, 184),
      Offset(142, 172),
      Offset(129, 147),
      Offset(140, 140),
      Offset(180, 110),
      Offset(220, 100),
      Offset(260, 95),
    ],
  };
}
