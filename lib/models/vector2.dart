import 'dart:ffi';

class Vector2 {
  final int x, y;

  Vector2(this.x, this.y);

  Vector2 operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  Vector2 operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  Vector2 operator *(double scalar) => Vector2((x * scalar).toInt(), (y * scalar).toInt());
  Vector2 operator /(double scalar) => Vector2((x / scalar).toInt(), (y / scalar).toInt());
  Vector2 operator -() => Vector2(-x, -y);
  bool operator ==(other) => other is Vector2 && x == other.x && y == other.y;
}