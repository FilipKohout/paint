import 'package:paint/models/line.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/renderable.dart';
import 'color.dart';

class Rectangle implements Renderable {
  Vector2 start;
  Vector2 end;
  List<Line> _lines = [];
  RGBA color;
  LineStyle style = LineStyle.solid;
  int thickness = 1;

  Rectangle(this.start, this.end, this.color, {this.thickness = 1, this.style = LineStyle.solid}) {
    updateLines();
  }

  void updateLines() {
    _lines = [
      Line(start, Vector2(end.x, start.y), color, style: style, thickness: thickness),
      Line(Vector2(end.x, start.y), end, color, style: style, thickness: thickness),
      Line(end, Vector2(start.x, end.y), color, style: style, thickness: thickness),
      Line(Vector2(start.x, end.y), start, color, style: style, thickness: thickness),
    ];
  }

  List<Pixel> pixelate() {
    List<Pixel> pixels = [];
    for (Line line in _lines) {
      pixels.addAll(line.pixelate());
    }
    return pixels;
  }
}