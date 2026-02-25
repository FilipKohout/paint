import 'package:paint/models/color.dart';
import 'package:paint/models/vector2.dart';

class Pixel {
  final Vector2 position;
  final RGBA color;
  final bool isFilled;

  Pixel(this.position, this.color, {this.isFilled = false});
}