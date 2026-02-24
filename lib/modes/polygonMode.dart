import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/mode.dart';
import '../models/color.dart';
import '../models/line.dart';

class PolygonMode implements Mode {
  late Line line;

  @override
  void onPanUpdate(Vector2 pos) {
    line.end = pos;
  }

  @override
  Renderable? onTapDown(Vector2 pos) {
    if (line.start != line.end) {
      line = Line(pos, pos, RGB(0, 0, 0));

      return line;
    }
    else {
      line.end = pos;
      return null;
    }
  }

  @override
  void onTapUp(Vector2 pos) {

  }
}