import 'package:paint/models/color.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

abstract class Renderable {
  bool foregroundOnly = false;
  RGBA color = RGBA(0, 0, 0, 255);

  List<Vector2> get nodes => [];
  Vector2 get minPosition => Vector2(0, 0);
  Vector2 get maxPosition => Vector2(0, 0);

  List<Pixel> pixelate();

  void move(Vector2 delta);
  void recalculate();
}