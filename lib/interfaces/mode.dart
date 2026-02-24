import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/vector2.dart';

abstract class Mode {
  Renderable? onTapDown(Vector2 pos);
  void onTapUp(Vector2 pos);
  void onPanUpdate(Vector2 pos);
}