import 'package:paint/models/color.dart';
import 'package:paint/models/vector2.dart';

class Pixel {
  final Vector2 position;
  final RGB color;

  Pixel(this.position, this.color);
}