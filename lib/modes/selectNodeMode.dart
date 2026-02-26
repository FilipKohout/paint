import 'package:flutter/services.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/fill.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/polygon.dart';
import 'package:paint/models/vector2.dart';

import '../interfaces/mode.dart';
import '../models/color.dart';
import '../models/line.dart';

class SelectNodeMode implements Mode {
  @override
  late RGBA color;

  @override
  late int thickness;

  @override
  late LineStyle style;
  
  @override
  void update(Vector2 pos) {
  }

  @override
  Renderable? start(Vector2 pos, List<Pixel> pixels, List<Renderable> objects) {

  }

  @override
  void end(Vector2 pos) {
  }

  @override
  void onKey(event) {

  }
}