import 'package:paint/models/circle.dart';
import 'package:paint/models/line.dart';
import 'package:paint/models/vector2.dart';

import 'color.dart';

class Eraser extends Circle {
  Eraser(Vector2 position, int thickness, RGBA color) : super(position, position + Vector2(thickness, thickness), color);

  @override
  bool foregroundOnly = true;

  @override
  int thickness = 50;
}