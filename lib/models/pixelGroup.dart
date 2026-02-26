
import 'dart:math';

import 'package:paint/config.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

import 'color.dart';

class PixelGroup implements Renderable {
  List<Pixel> pixels = [];

  @override
  List<Vector2> get nodes => [];

  @override
  RGBA color;

  @override
  bool foregroundOnly = false;

  @override
  bool deleted = false;

  @override
  Vector2 get maxPosition {
    int x = pixels.map((p) => p.position.x).reduce(max);
    int y = pixels.map((p) => p.position.y).reduce(max);
    return Vector2(x, y);
  }

  @override
  Vector2 get minPosition {
    int x = pixels.map((p) => p.position.x).reduce(min);
    int y = pixels.map((p) => p.position.y).reduce(min);
    return Vector2(x, y);
  }

  PixelGroup(this.pixels, this.color);

  @override
  List<Pixel> pixelate() => pixels;

  @override
  void move(Vector2 delta) {
    for (Pixel p in pixels) {
      p.position += delta;
    }
  }

  @override
  void recalculate() {

  }
}