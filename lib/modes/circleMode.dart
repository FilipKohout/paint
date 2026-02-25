import 'dart:math';

import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/circle.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/polygon.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/mode.dart';
import '../models/color.dart';
import '../models/line.dart';

class CircleMode implements Mode {
  @override
  late RGBA color;

  @override
  late int thickness;

  @override
  late LineStyle style;

  Circle? circle;
  bool isDrawing = false;

  @override
  void update(Vector2 pos) {
    if (isDrawing && circle != null) {
      circle!.end = pos;
    }
  }

  @override
  Renderable? start(Vector2 pos, List<Pixel> pixels) {
    if (!isDrawing) {
      circle = Circle(pos, pos, color, thickness: thickness, style: style);
      isDrawing = true;

      return circle;
    } else {
      circle!.end = pos;
      isDrawing = false;
      circle = null;

      return null;
    }
  }

  @override
  void end(Vector2 pos) {
    if (isDrawing && circle != null) {
      double dx = (circle!.start.x - circle!.end.x).toDouble();
      double dy = (circle!.start.y - circle!.end.y).toDouble();
      double distance = sqrt(dx * dx + dy * dy);

      if (distance > 5) {
        isDrawing = false;
        circle = null;
      }
    }
  }

  @override
  void onKey(event) {

  }
}