import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/fill.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/polygon.dart';
import 'package:paint/models/rectangle.dart';
import 'package:paint/models/selectionBox.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/mode.dart';
import '../models/color.dart';
import '../models/line.dart';

class SelectObjectMode implements Mode {
  @override
  late RGBA color;

  @override
  late int thickness;

  @override
  late LineStyle style;

  Map<Renderable, List<Pixel>> linkedPixels = {};
  Renderable? selectedObject;
  Vector2? lastMousePos;

  late SelectionBox selectBox;

  SelectObjectMode() {
    selectBox = SelectionBox(Vector2(-5, -5), Vector2(-5, -5), RGBA(0, 0, 0, 0))..foregroundOnly = true;
  }

  Renderable? getObjectAtPosition(Vector2 pos) {
    for (Renderable obj in linkedPixels.keys) {
      var pixels = linkedPixels[obj]!;

      for (Pixel pixel in pixels) {
        if ((pixel.position - pos).magnitude < 1) {
          return obj;
        }
      }
    }
    return null;
  }

  void _updateSelectionBox(Vector2 pos) {
    if (selectedObject == null) {
      Renderable? detectedObject = getObjectAtPosition(pos);

      if (detectedObject != null) {
        selectBox.start = detectedObject.minPosition;
        selectBox.end = detectedObject.maxPosition;
        selectBox.color = detectedObject.color.isDark ? RGBA(255, 0, 0, 100) : RGBA(0, 0, 0, 100);
        selectBox.recalculate();
      } else {
        selectBox.color = RGBA(0, 0, 0, 0);
        selectBox.recalculate();
      }
    } else {
      selectBox.start = selectedObject!.minPosition;
      selectBox.end = selectedObject!.maxPosition;
      selectBox.color = selectedObject!.color.isDark ? RGBA(255, 0, 0, 200) : RGBA(0, 0, 0, 200);
      selectBox.recalculate();
    }
  }

  @override
  void update(Vector2 pos) {
    if (selectedObject != null && lastMousePos != null) {
      Vector2 delta = pos - lastMousePos!;

      selectedObject!.move(delta);
      lastMousePos = pos;
    }

    _updateSelectionBox(pos);
  }

  @override
  Renderable? start(Vector2 pos, List<Pixel> pixels, List<Renderable> objects) {
    linkedPixels = {};
    for (Renderable obj in objects) {
      linkedPixels[obj] = obj.pixelate();
    }

    Renderable? detectedObject = getObjectAtPosition(pos);
    selectedObject = detectedObject;

    if (selectedObject != null) selectedObject!.foregroundOnly = true;

    _updateSelectionBox(pos);
    lastMousePos = pos;

    return selectBox;
  }

  @override
  void end(Vector2 pos) {
    if (selectedObject != null) selectedObject!.foregroundOnly = false;
    lastMousePos = null;
  }

  @override
  void onKey(event) {}
}
