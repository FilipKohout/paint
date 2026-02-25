import 'package:paint/models/line.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/renderable.dart';
import 'color.dart';

class Polygon implements Renderable {
  List<Vector2> _points = [];
  List<Line> _lines = [];
  RGBA color;
  LineStyle style = LineStyle.solid;
  int thickness = 1;

  Polygon(Vector2 start, this.color, {this.thickness = 1, this.style = LineStyle.solid}) {
    addPoint(start);
  }

  void addPoint(Vector2 point) {
    _points.add(point);
    _refreshLines();
  }

  void removeLastPoint() {
    if (_points.isNotEmpty) {
      _points.removeLast();
      _refreshLines();
    }
  }

  void _refreshLines() {
    _lines = [];

    for (int i = 0; i < _points.length - 1; i++) {
      _lines.add(Line(_points[i], _points[i + 1], color, style: style, thickness: thickness));
    }

    _lines.add(Line(_points.last, _points.first, color, style: style, thickness: thickness));
  }

  void updateLastPoint(Vector2 point) {
    if (_points.isNotEmpty) {
      _points[_points.length - 1] = point;
      _refreshLines();
    }
  }

  List<Pixel> pixelate() {
    List<Pixel> pixels = [];
    for (Line line in _lines) {
      pixels.addAll(line.pixelate());
    }
    return pixels;
  }
}