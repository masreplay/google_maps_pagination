import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_pagination/models/marker_decorations.dart';

Future<BitmapDescriptor> getMarkerBitmap({
  required String text,
  required MarkerDecorations markerDecorations,
}) async {
  if (markerDecorations.width == null) {
    markerDecorations = markerDecorations.copyWith(
      width: text.getWidth(),
    );
  }

  double width = markerDecorations.width! * 4;
  double height = markerDecorations.height;

  double radius = markerDecorations.radius ?? width;
  double arrowWidth = height / 3;
  double arrowHeight = height / 5;
  double arrowRadius = 0.5;

  double shadowOffset = 10.0;

  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = markerDecorations.color;

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
    ..color = markerDecorations.strokeColor
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = markerDecorations.strokeWidth;

  canvas.drawPath(path, borderPaint);

  /// draw speech dialog
  canvas.drawPath(path, paint);

  /// text
  TextPainter painter =
      TextPainter(textDirection: markerDecorations.textDirection);
  painter.text = TextSpan(
    text: text,
    style: TextStyle(
      fontSize: markerDecorations.fontSize,
      color: markerDecorations.textColor,
      fontWeight: markerDecorations.fontWeight,
      fontFamily: markerDecorations.familyFont,
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
