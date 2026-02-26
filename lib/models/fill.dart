
import 'dart:math';

import 'package:paint/config.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

import 'color.dart';

class Fill implements Renderable {
  Vector2 position;
  List<Pixel> allPixels = [];
  List<Pixel> filledPixels = [];

  @override
  RGBA color;

  @override
  bool foregroundOnly = false;

  @override
  Vector2 get maxPosition {
    if (filledPixels.isEmpty) return position;
    int x = filledPixels.map((p) => p.position.x).reduce(max);
    int y = filledPixels.map((p) => p.position.y).reduce(max);
    return Vector2(x, y);
  }

  @override
  Vector2 get minPosition {
    if (filledPixels.isEmpty) return position;
    int x = filledPixels.map((p) => p.position.x).reduce(min);
    int y = filledPixels.map((p) => p.position.y).reduce(min);
    return Vector2(x, y);
  }

  Fill(this.position, this.color, this.allPixels);

  @override
  List<Pixel> pixelate() {
    if (filledPixels.isEmpty) {
      int width = Config.width;
      int height = Config.height;

      List<bool> isObstacle = List.filled(width * height, false);
      for (Pixel p in allPixels) {
        if (!p.isFilled && p.color.a != 0 && p.position.x >= 0 && p.position.x < width && p.position.y >= 0 && p.position.y < height) {
          isObstacle[p.position.y * width + p.position.x] = true;
        }
      }

      List<int> stack = [];
      List<bool> visited = List.filled(width * height, false);

      stack.add(position.y * width + position.x);

      while (stack.isNotEmpty) {
        int currIndex = stack.removeLast();

        if (visited[currIndex]) continue;
        visited[currIndex] = true;

        if (isObstacle[currIndex]) continue;

        int cx = currIndex % width;
        int cy = currIndex ~/ width;

        filledPixels.add(Pixel(Vector2(cx, cy), color, isFilled: true));

        if (cx + 1 < width) stack.add(currIndex + 1);
        if (cx - 1 >= 0) stack.add(currIndex - 1);
        if (cy + 1 < height) stack.add(currIndex + width);
        if (cy - 1 >= 0) stack.add(currIndex - width);
      }
    }

    return filledPixels;
  }

  @override
  void move(Vector2 delta) {
    for (Pixel p in filledPixels) {
      p.position += delta;
    }
  }
}