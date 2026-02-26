import 'package:paint/models/line.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/renderable.dart';
import 'color.dart';

class Polygon implements Renderable {
  List<Vector2> _points = [];
  List<Line> _lines = [];
  LineStyle style = LineStyle.solid;
  int thickness = 1;

  @override
  List<Vector2> get nodes => _points;

  @override
  RGBA color;

  @override
  bool foregroundOnly = false;

  @override
  Vector2 get maxPosition => Vector2(
    _points.map((point) => point.x).reduce((a, b) => a > b ? a : b),
    _points.map((point) => point.y).reduce((a, b) => a > b ? a : b),
  );

  @override
  Vector2 get minPosition => Vector2(
    _points.map((point) => point.x).reduce((a, b) => a < b ? a : b),
    _points.map((point) => point.y).reduce((a, b) => a < b ? a : b),
  );

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
    for (int i = 0; i < _points.length; i++) {
      _points[i] = _points[i] + delta;
    }
    _refreshLines();
  }

  @override
  void recalculate() {

  }
}