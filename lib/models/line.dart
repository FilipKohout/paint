import 'dart:ui';

import 'package:paint/interfaces/renderize.dart';
import 'package:paint/models/color.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

class Line implements Renderable {
  final Vector2 start;
  final Vector2 end;
  final RGB color;

  Line(this.start, this.end, this.color);

  List<Pixel> pixelate() {
    List<Pixel> pixels = [];
    double a = (end.y - start.y) / (end.x - start.x);
    double b = start.y - a * start.x;

    if (a.abs() <= 1) {
      for (int x = start.x; x <= end.x; x++) {
        double y = a * x + b;
        pixels.add(Pixel(Vector2(x, y as int), color));
      }
    } else {
      for (int y = start.y; y <= end.y; y++) {
        double x = (y - b) / a;
        pixels.add(Pixel(Vector2(x as int, y), color));
      }
    }

    return pixels;
  }
}