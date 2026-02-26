import 'package:flutter/rendering.dart' hide SelectionPoint;
import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/fill.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/polygon.dart';
import 'package:paint/models/rectangle.dart';
import 'package:paint/models/selectionBox.dart';
import 'package:paint/models/selectionPointsRender.dart';
import 'package:paint/models/vector2.dart';
import "package:paint/models/selectionPoint.dart";

import '../interfaces/mode.dart';
import '../models/color.dart';
import '../models/line.dart';

class SelectNodeMode implements Mode {
  @override
  late RGBA color;

  @override
  late int thickness;

  @override
  late LineStyle style;

  Map<Renderable, List<Vector2>> linkedNodes = {};
  Renderable? selectedObject;
  Vector2? selectedNode;

  late SelectionPointsRender selectionRender;

  SelectNodeMode() {
    selectionRender = SelectionPointsRender();
  }

  Vector2? lastMousePos;

  (Renderable?, Vector2?) getNodeAtPosition(Vector2 pos) {
    for (Renderable obj in linkedNodes.keys) {
      var nodes = linkedNodes[obj]!;

      for (Vector2 node in nodes) {
        if ((node - pos).magnitude < 10) {
          return (obj, node);
        }
      }
    }
    return (null, null);
  }

  @override
  void update(Vector2 pos) {
    if (selectedObject != null && lastMousePos != null && selectedNode != null) {
      SelectionPoint point = selectionRender.points.firstWhere((p) => p.start == selectedNode);
      Vector2 delta = pos - lastMousePos!;

      selectedNode!.x += delta.x;
      selectedNode!.y += delta.y;
      selectedObject!.recalculate();

      point.end = selectedNode! + Vector2(5, 5);
      lastMousePos = pos;
    }
  }

  @override
  Renderable? start(Vector2 pos, List<Pixel> pixels, List<Renderable> objects) {
    linkedNodes = {};
    selectionRender.points = [];

    for (Renderable obj in objects) {
      if (obj.foregroundOnly) continue;

      linkedNodes[obj] = obj.nodes;

      for (Vector2 node in obj.nodes) {
        selectionRender.points.add(SelectionPoint(node, obj.color.isDark ? RGBA(255, 0, 0, 200) : RGBA(0, 0, 0, 200)));
      }
    }

    var (detectedObject, node) = getNodeAtPosition(pos);
    selectedObject = detectedObject;
    selectedNode = node;

    if (selectedObject != null) selectedObject!.foregroundOnly = true;

    lastMousePos = pos;

    return selectionRender;
  }

  @override
  void end(Vector2 pos) {
    if (selectedObject != null) selectedObject!.foregroundOnly = false;
    lastMousePos = null;
  }

  @override
  void onKey(event) {}
}
