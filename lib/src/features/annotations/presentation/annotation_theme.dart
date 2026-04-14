import 'package:flutter/material.dart';

const annotationHighlightPalette = <Color>[
  Color(0xFF8BC34A),
  Color(0xFFFFEB3B),
  Color(0xFFFFC107),
  Color(0xFF4DD0E1),
  Color(0xFFCE93D8),
  Color(0xFFFFAB91),
  Color(0xFF90CAF9),
];

Color annotationColorFromValue(int? value, Color fallback) {
  if (value == null) return fallback;
  return Color(value);
}
