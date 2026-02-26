import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/line.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';

import '../models/color.dart';

abstract class Mode {
  late RGBA color;
  late int thickness;
  late LineStyle style;

  Renderable? start(Vector2 pos, List<Pixel> pixels, List<Renderable> objects);
  void update(Vector2 pos);
  void end(Vector2 pos);
  void onKey(KeyEvent event);
}