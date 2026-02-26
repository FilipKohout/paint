import 'package:paint/models/circle.dart';
import 'package:paint/models/line.dart';
import 'package:paint/models/vector2.dart';

import 'color.dart';

class SelectionPoint extends Circle {
  SelectionPoint(Vector2 position, RGBA color) : super(position, position + Vector2(5, 5), color);

  @override
  bool foregroundOnly = true;

  @override
  int thickness = 15;
}