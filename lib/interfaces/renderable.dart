import 'package:paint/models/pixel.dart';

abstract class Renderable {
  List<Pixel> pixelate();
}