import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/polygon.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/mode.dart';
import '../models/color.dart';
import '../models/line.dart';
import '../models/pixel.dart';

class PolygonMode implements Mode {
  @override
  late RGBA color;

  @override
  late int thickness;

  @override
  late LineStyle style;

  Polygon? polygon;

  @override
  void update(Vector2 pos) {
    if (polygon == null) return;

    polygon!.updateLastPoint(pos);
  }

  @override
  Renderable? start(Vector2 pos, List<Pixel> pixels, List<Renderable> objects) {
    if (polygon != null) return null;

    polygon = Polygon(pos, color, thickness: thickness, style: style);
    return polygon;
  }

  @override
  void end(Vector2 pos) {
    if (polygon == null) return;

    polygon!.addPoint(pos);
  }

  @override
  void onKey(event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        polygon?.removeLastPoint();
        polygon = null;
        break;
    }
  }
}