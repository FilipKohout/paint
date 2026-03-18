import 'dart:math';

import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/circle.dart';
import 'package:paint/models/fill.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/pixelGroup.dart';
import 'package:paint/models/polygon.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/mode.dart';
import '../models/color.dart';
import '../models/eraser.dart';
import '../models/line.dart';

class EraseMode implements Mode {
  @override
  late RGBA color;

  @override
  late int thickness;

  @override
  late LineStyle style;

  Map<Renderable, List<Pixel>> linkedPixels = {};
  List<Renderable> savedObjects = [];
  bool isErasing = false;

  Eraser? eraser;

  EraseMode() {
    eraser = Eraser(Vector2(0, 0), 0, RGBA(255, 0, 0, 255));
  }

  @override
  void update(Vector2 pos) {
    if (eraser == null) return;

    eraser!.start = pos;
    eraser!.end = pos + Vector2(thickness, thickness);

    if (!isErasing) return;

    int thickSq = thickness * thickness;

    for (Renderable obj in linkedPixels.keys.toList()) {
      if (obj.foregroundOnly || obj.deleted) continue;

      var pixels = linkedPixels[obj]!;
      int initialCount = pixels.length;

      pixels.removeWhere((pixel) {
        int dx = pixel.position.x - pos.x;
        int dy = pixel.position.y - pos.y;
        return (dx * dx + dy * dy) <= thickSq;
      });

      bool modified = pixels.length < initialCount;

      if (modified) {
        if (obj is PixelGroup) obj.pixels = pixels;
        else {
          savedObjects.remove(obj);
          obj.deleted = true;

          var newGroup = PixelGroup(pixels, obj.color);
          savedObjects.add(newGroup);

          linkedPixels.remove(obj);
          linkedPixels[newGroup] = pixels;
        }
      }
    }
  }

  @override
  Renderable? start(Vector2 pos, List<Pixel> pixels, List<Renderable> objects) {
    linkedPixels = {};
    for (Renderable obj in objects) {
      linkedPixels[obj] = obj.pixelate();
    }

    savedObjects = objects;
    isErasing = true;
    update(pos);

    return eraser;
  }

  @override
  void end(Vector2 pos) {
    isErasing = false;
  }

  @override
  void onKey(event) {

  }
}