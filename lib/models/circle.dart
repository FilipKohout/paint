import 'dart:math';
import 'dart:ui';

import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/color.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

import 'fill.dart';
import 'line.dart';

class Circle implements Renderable {
  Vector2 start;
  Vector2 end;
  LineStyle style;
  int thickness;

  @override
  List<Vector2> get nodes => [start, end];

  @override
  RGBA color;

  @override
  bool foregroundOnly = false;

  @override
  bool deleted = false;

  double get dx => (end.x - start.x).toDouble();
  double get dy => (end.y - start.y).toDouble();
  int get radius => sqrt(dx * dx + dy * dy).round();

  @override
  Vector2 get maxPosition => Vector2(start.x - radius, start.y - radius);

  @override
  Vector2 get minPosition => Vector2(start.x + radius, start.y + radius);

  Circle(this.start, this.end, this.color, {this.style = LineStyle.solid, this.thickness = 5});

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

  @override
  List<Pixel> pixelate() {
    List<Pixel> pixels = [];

    if (start.x == end.x && start.y == end.y) {
      pixels.add(Pixel(start, color));
      return pixels;
    }

    int cx = start.x;
    int cy = start.y;
    int rOuter = radius;
    int rInner = max(0, radius - thickness);

    int rOuterSq = rOuter * rOuter;
    int rInnerSq = rInner * rInner;

    for (int y = 0; y <= rOuter; y++) {
      int xOuter = sqrt(rOuterSq - y * y).round();
      int xInner = (y < rInner) ? sqrt(rInnerSq - y * y).round() : 0;

      for (int x = xInner; x <= xOuter; x++) {
        if (!_canDraw(x + y)) continue;

        pixels.add(Pixel(Vector2(cx + x, cy + y), color));

        if (x != 0) pixels.add(Pixel(Vector2(cx - x, cy + y), color));
        if (y != 0) pixels.add(Pixel(Vector2(cx + x, cy - y), color));
        if (x != 0 && y != 0) pixels.add(Pixel(Vector2(cx - x, cy - y), color));
      }
    }

    return pixels;
  }

  @override
  void move(Vector2 delta) {
    start += delta;
    end += delta;
  }

  @override
  void recalculate() {

  }
}