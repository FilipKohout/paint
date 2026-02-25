import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/mode.dart';
import '../models/color.dart';
import '../models/line.dart';

class LineMode implements Mode {
  @override
  late RGBA color;

  @override
  late int thickness;

  @override
  late LineStyle style;

  Line? line;
  bool isDrawing = false;
  bool snap = false;

  @override
  void update(Vector2 pos) {
    if (isDrawing && line != null) {
      Vector2 endPos = pos;

      if (snap) {
        int realDx = pos.x - line!.start.x;
        int realDy = pos.y - line!.start.y;
        int absDx = realDx.abs();
        int absDy = realDy.abs();

        if (absDx > absDy * 2) {
          endPos = Vector2(pos.x, line!.start.y);
        } else if (absDy > absDx * 2) {
          endPos = Vector2(line!.start.x, pos.y);
        } else {
          int size = math.min(absDx, absDy);

          endPos = Vector2(
            line!.start.x + (size * realDx.sign),
            line!.start.y + (size * realDy.sign),
          );
        }
      }

      line!.end = endPos;
    }
  }

  @override
  Renderable? start(Vector2 pos) {
    if (!isDrawing) {
      line = Line(pos, pos, color, thickness: thickness, style: style);
      isDrawing = true;

      return line;
    } else {
      line!.end = pos;
      isDrawing = false;
      line = null;

      return null;
    }
  }

  @override
  void end(Vector2 pos) {
    if (isDrawing && line != null) {
      double dx = (line!.start.x - line!.end.x).toDouble();
      double dy = (line!.start.y - line!.end.y).toDouble();
      double distance = math.sqrt(dx * dx + dy * dy);

      if (distance > 5) {
        isDrawing = false;
        line = null;
      }
    }
  }

  @override
  void onKey(event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.shiftLeft:
        snap = event is! KeyUpEvent;
        break;
    }
  }
}