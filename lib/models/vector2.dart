import 'dart:ffi';
import 'dart:math';

class Vector2 {
  int x, y;

  Vector2(this.x, this.y);

  get magnitude => sqrt((x * x + y * y).toDouble());

  Vector2 operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  Vector2 operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  Vector2 operator *(double scalar) => Vector2((x * scalar).toInt(), (y * scalar).toInt());
  Vector2 operator /(double scalar) => Vector2((x / scalar).toInt(), (y / scalar).toInt());
  Vector2 operator -() => Vector2(-x, -y);
  bool operator ==(other) => other is Vector2 && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}