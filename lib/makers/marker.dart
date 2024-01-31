import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getMarkerBitmap({
  double? size,
  required String text,
  required Color color,
  double strokeWidth = 4,
  Color strokeColor = Colors.white,
  Color textColor = Colors.white,
  TextDirection textDirection = TextDirection.rtl,
  String? familyFont,
}) async {
  size ??= text.getWidth();
  double width = size * 4;
  double height = 100;

  double radius = size / 5;
  double arrowWidth = height / 3;
  double arrowHeight = height / 5;
  double arrowRadius = 0.5;

  double shadowOffset = 10.0;

  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = color;

  /// if right is less than left or bottom is less than top then the rectangle is not drawn
  var rect = Rect.fromLTRB(width - 4, height - 4, 4, 4);

  rect = Rect.fromPoints(rect.topLeft, rect.bottomRight);
  double x = arrowWidth, y = arrowHeight, r = 1 - arrowRadius;
  var path = Path()
    ..moveTo(rect.bottomCenter.dx + x / 2, rect.bottomCenter.dy)
    ..relativeLineTo(-x / 2 * r, y * r)
    ..relativeQuadraticBezierTo(-x / 2 * (1 - r), y * (1 - r), -x * (1 - r), 0)
    ..relativeLineTo(-x / 2 * r, -y * r)
    ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
    ..close();

  /// border
  Paint borderPaint = Paint()
    ..color = strokeColor
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = strokeWidth;

  canvas.drawPath(path, borderPaint);

  /// draw speech dialog
  canvas.drawPath(path, paint);

  /// text
  TextPainter painter = TextPainter(textDirection: textDirection);
  painter.text = TextSpan(
    text: text,
    style: TextStyle(
      fontSize: 35,
      color: textColor,
      fontWeight: FontWeight.bold,
      fontFamily: familyFont,
    ),
  );
  painter.layout();
  painter.paint(
    canvas,
    Offset((width / 2 - painter.width / 2), height / 2 - painter.height / 2),
  );

  final img = await pictureRecorder
      .endRecording()
      .toImage(width.toInt(), (height + arrowHeight + shadowOffset).toInt());
  final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}

extension StringExtension on String {
  double getWidth() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: this),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width + 10;
  }
}
