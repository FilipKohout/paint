import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/color.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';
import 'package:paint/models/selectionPoint.dart';

class SelectionPointsRender implements Renderable {
  List<SelectionPoint> points = [];

  @override
  List<Vector2> get nodes => [];

  @override
  bool foregroundOnly = true;

  @override
  bool deleted = false;

  @override
  RGBA color = RGBA(0, 0, 255, 255);

  @override
  get maxPosition => Vector2(0, 0);

  @override
  get minPosition => Vector2(0, 0);

  @override
  List<Pixel> pixelate() {
    List<Pixel> pixels = [];

    for (SelectionPoint point in points) {
      pixels.addAll(point.pixelate());
    }

    return pixels;
  }

  @override
  void move(delta) {

  }

  @override
  void recalculate() {

  }
}