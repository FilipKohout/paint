import 'dart:ui';

import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/color.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

enum LineStyle { solid, dashed, dotted }

class Line implements Renderable {
  Vector2 start;
  Vector2 end;
  RGB color;
  LineStyle style;

  Line(this.start, this.end, this.color, this.style);

  bool _canDraw(int index) {
    switch(style) {
      case (LineStyle.dashed):
        return (index ~/ 5) % 2 == 0;
      case (LineStyle.dotted):
        return index % 5 == 0;
      default:
        return true;
    }
  }

  List<Pixel> pixelate() {
    List<Pixel> pixels = [];

    if (start.x == end.x && start.y == end.y) {
      pixels.add(Pixel(start, color));
      return pixels;
    }

    if (start.x == end.x) {
      Vector2 p1 = start.y < end.y ? start : end;
      Vector2 p2 = start.y < end.y ? end : start;

      for (int y = p1.y; y <= p2.y; y++) {
        if (_canDraw(y - p1.y)) { pixels.add(Pixel(Vector2(start.x, y), color)); }
      }
      return pixels;
    }

    double a = (end.y - start.y) / (end.x - start.x);
    double b = start.y - a * start.x;

    if (a.abs() <= 1) {
      Vector2 p1 = start.x < end.x ? start : end;
      Vector2 p2 = start.x < end.x ? end : start;

      for (int x = p1.x; x <= p2.x; x++) {
        double y = a * x + b;

        if (_canDraw(x - p1.x)) {
          pixels.add(Pixel(Vector2(x, y.toInt()), color));
        }
      }
    } else {
      Vector2 p1 = start.y < end.y ? start : end;
      Vector2 p2 = start.y < end.y ? end : start;

      for (int y = p1.y; y <= p2.y; y++) {
        double x = (y - b) / a;

        if (_canDraw(y - p1.y)) {
          pixels.add(Pixel(Vector2(x.toInt(), y), color));
        }
      }
    }

    return pixels;
  }
}