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
    eraser!.start = pos;
    eraser!.end = pos + Vector2(thickness, thickness);

    if (isErasing) {
      for (Renderable obj in linkedPixels.keys) {
        if (obj.foregroundOnly || obj.deleted) continue;

        var pixels = linkedPixels[obj]!;
        var toRemove = <Pixel>[];
        bool modified = false;

        for (Pixel pixel in pixels) {
          if ((pixel.position - pos).magnitude < thickness) {
            toRemove.add(pixel);
            modified = true;
          }
        }

        for (Pixel pixel in toRemove) {
          pixels.remove(pixel);
        }

        if (modified && obj is! PixelGroup) {
          savedObjects.remove(obj);
          obj.deleted = true;
          savedObjects.add(PixelGroup(pixels, obj.color));
        } else if (modified) {
          (obj as PixelGroup).pixels = pixels;
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