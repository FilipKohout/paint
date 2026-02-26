import 'package:paint/models/line.dart';
import 'package:paint/models/rectangle.dart';

class SelectionBox extends Rectangle {
  SelectionBox(super.start, super.end, super.color);

  @override
  bool foregroundOnly = true;

  @override
  int get thickness => 3;

  @override
  LineStyle style = LineStyle.dashed;
}