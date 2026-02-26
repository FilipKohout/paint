import 'package:paint/models/line.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/renderable.dart';
import 'color.dart';

class Rectangle implements Renderable {
  Vector2 start;
  Vector2 end;
  List<Line> _lines = [];
  LineStyle style = LineStyle.solid;
  int thickness = 1;

  @override
  List<Vector2> get nodes => [start, end];

  @override
  RGBA color;

  @override
  bool foregroundOnly = false;

  @override
  bool deleted = false;

  @override
  Vector2 get maxPosition => start;

  @override
  Vector2 get minPosition => end;

  Rectangle(this.start, this.end, this.color, {this.thickness = 1, this.style = LineStyle.solid}) {
    recalculate();
  }

  @override
  List<Pixel> pixelate() {
    List<Pixel> pixels = [];
    for (Line line in _lines) {
      pixels.addAll(line.pixelate());
    }
    return pixels;
  }

  @override
  void move(Vector2 delta) {
    start += delta;
    end += delta;
    recalculate();
  }

  @override
  void recalculate() {
    _lines = [
      Line(start, Vector2(end.x, start.y), color, style: style, thickness: thickness),
      Line(Vector2(end.x, start.y), end, color, style: style, thickness: thickness),
      Line(end, Vector2(start.x, end.y), color, style: style, thickness: thickness),
      Line(Vector2(start.x, end.y), start, color, style: style, thickness: thickness),
    ];
  }
}