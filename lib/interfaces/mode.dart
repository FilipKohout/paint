import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/vector2.dart';

abstract class Mode {
  Renderable? start(Vector2 pos);
  void update(Vector2 pos);
  void end(Vector2 pos);
  void onKey(KeyEvent event);
}