import 'package:paint/models/color.dart';
import 'package:paint/models/vector2.dart';

class Pixel {
  Vector2 position;
  RGBA color;
  bool isFilled;

  Pixel(this.position, this.color, {this.isFilled = false});
}