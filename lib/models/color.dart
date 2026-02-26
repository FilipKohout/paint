class RGBA {
  final double r;
  final double g;
  final double b;
  final double a;

  RGBA(double r, double g, double b, [double a = 255])
      : r = r.clamp(0, 255),
        g = g.clamp(0, 255),
        b = b.clamp(0, 255),
        a = a.clamp(0, 255);

  bool get isDark => (r + g + b) / 3 < 128;
  bool get isTransparent => a < 255;
}