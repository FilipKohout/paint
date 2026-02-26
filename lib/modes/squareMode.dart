import 'dart:math';

import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/circle.dart';
import 'package:paint/models/rectangle.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/polygon.dart';
import 'package:paint/models/vector2.dart';
import 'package:paint/modes/rectangleMode.dart';

import '../interfaces/mode.dart';
import '../models/color.dart';
import '../models/line.dart';

class SquareMode extends RectangleMode {
  @override
  void update(Vector2 pos) {
    Vector2 start = rectangle!.start;
    int dx = pos.x - start.x;
    int dy = pos.y - start.y;
    int size = ((dx.abs() + dy.abs()) / 2).round();

    super.update(Vector2(start.x + size * dx.sign, start.y + size * dy.sign));
  }
}