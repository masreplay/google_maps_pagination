// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class MarkerDecorations {
  final double? width;
  final double height;

  final double? radius;
  final Color strokeColor;
  final double strokeWidth;
  final String? familyFont;
  final Color color;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final TextDirection textDirection;

  MarkerDecorations({
    this.width,
    this.height = 100,
    this.strokeColor = Colors.white,
    this.strokeWidth = 4,
    this.familyFont,
    this.color = Colors.black,
    this.textColor = Colors.white,
    this.textDirection = TextDirection.ltr,
    this.fontSize = 35,
    this.fontWeight = FontWeight.bold,
    this.radius,
  });

  MarkerDecorations copyWith({
    double? width,
    double? height,
    double? radius,
    Color? strokeColor,
    double? strokeWidth,
    String? familyFont,
    Color? color,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    TextDirection? textDirection,
  }) {
    return MarkerDecorations(
      width: width ?? this.width,
      radius: radius ?? this.radius,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      familyFont: familyFont ?? this.familyFont,
      color: color ?? this.color,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textDirection: textDirection ?? this.textDirection,
      height: height ?? this.height,
    );
  }
}
