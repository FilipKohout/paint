import 'dart:math';
import 'dart:ui';

import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/color.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

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

    for (int t = 0; t < thickness; t++) {
      int r = radius - t;
      if (r < 0) break;

      int x = r;
      int y = 0;
      int p = 1 - r;
      int i = 0;

      while (x >= y) {
        if (_canDraw(i)) {
          pixels.add(Pixel(Vector2(cx + x, cy + y), color));
          pixels.add(Pixel(Vector2(cx - x, cy + y), color));
          pixels.add(Pixel(Vector2(cx + x, cy - y), color));
          pixels.add(Pixel(Vector2(cx - x, cy - y), color));
          pixels.add(Pixel(Vector2(cx + y, cy + x), color));
          pixels.add(Pixel(Vector2(cx - y, cy + x), color));
          pixels.add(Pixel(Vector2(cx + y, cy - x), color));
          pixels.add(Pixel(Vector2(cx - y, cy - x), color));
        }

        i++;
        y++;
        if (p <= 0) {
          p = p + 2 * y + 1;
        } else {
          x--;
          p = p + 2 * y - 2 * x + 1;
        }
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