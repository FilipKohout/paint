import 'dart:math';

import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/circle.dart';
import 'package:paint/models/rectangle.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/polygon.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/mode.dart';
import '../models/color.dart';
import '../models/line.dart';

class RectangleMode implements Mode {
  @override
  late RGBA color;

  @override
  late int thickness;

  @override
  late LineStyle style;

  Rectangle? rectangle;
  bool isDrawing = false;

  @override
  void update(Vector2 pos) {
    if (isDrawing && rectangle != null) {
      rectangle!.end = pos;
      rectangle!.updateLines();
    }
  }

  @override
  Renderable? start(Vector2 pos, List<Pixel> pixels, List<Renderable> objects) {
    if (!isDrawing) {
      rectangle = Rectangle(pos, pos, color, thickness: thickness, style: style);
      isDrawing = true;

      return rectangle;
    } else {
      rectangle!.end = pos;
      isDrawing = false;
      rectangle = null;

      return null;
    }
  }

  @override
  void end(Vector2 pos) {
    if (isDrawing && rectangle != null) {
      double dx = (rectangle!.start.x - rectangle!.end.x).toDouble();
      double dy = (rectangle!.start.y - rectangle!.end.y).toDouble();
      double distance = sqrt(dx * dx + dy * dy);

      if (distance > 5) {
        isDrawing = false;
        rectangle = null;
      }
    }
  }

  @override
  void onKey(event) {

  }
}