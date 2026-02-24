  import 'dart:typed_data';
  import 'dart:ui' as ui;

  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:paint/interfaces/mode.dart';
  import 'package:paint/interfaces/renderable.dart';
  import 'package:paint/models/pixel.dart';
  import 'package:paint/models/vector2.dart';
  import 'package:paint/modes/polygonMode.dart';

  import 'modes/lineMode.dart';

  void main() {
    runApp(const App());
  }

  class App extends StatelessWidget {
    const App({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Paint',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
          useMaterial3: true,
        ),
        home: const MainPage(),
      );
    }
  }

  class MainPage extends StatefulWidget {
    const MainPage({super.key});

    @override
    State<MainPage> createState() => _MainPageState();
  }

  class _MainPageState extends State<MainPage> {
    final int width = 800;
    final int height = 600;

    late Uint8List pixels;
    late List<Renderable> objects = [];
    late Mode mode = LineMode();

    ui.Image? renderImage;

    void _fillCanvasWhite() {
      for (int i = 0; i < pixels.length; i += 4) {
        pixels[i] = 255;     // R
        pixels[i + 1] = 255; // G
        pixels[i + 2] = 255; // B
        pixels[i + 3] = 255; // Alpha
      }
    }

    void _redrawCanvas() {
      _fillCanvasWhite();

      for (var object in objects) {
        for (Pixel p in object.pixelate()) {
          _setPixel(p);
        }
      }

      _updateCanvas();
    }

    void _setPixel(Pixel p) {
      if (p.position.x >= 0 && p.position.x < width && p.position.y >= 0 && p.position.y < height) {
        int index = (p.position.y * width + p.position.x) * 4;
        pixels[index] = p.color.r;
        pixels[index + 1] = p.color.g;
        pixels[index + 2] = p.color.b;
        pixels[index + 3] = 255;
      }
    }

    bool _onKey(KeyEvent event) {
      mode.onKey(event);
      _redrawCanvas();
      return true;
    }

    Future<void> _updateCanvas() async {
      ui.decodeImageFromPixels(pixels, width, height, ui.PixelFormat.rgba8888, (ui.Image img) {
        setState(() {
          renderImage = img;
        });
      });
    }

    @override
    void initState() {
      super.initState();
      ServicesBinding.instance.keyboard.addHandler(_onKey);

      pixels = Uint8List(width * height * 4);
      _fillCanvasWhite();
    }

    @override
    void dispose() {
      ServicesBinding.instance.keyboard.removeHandler(_onKey);
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: [
            Container(
              height: 50,
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    IconButton(
                      icon: const Icon(Icons.linear_scale, size: 20),
                      tooltip: 'Line',
                      isSelected: mode is LineMode,
                      onPressed: () => setState(() => mode = LineMode()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.polyline, size: 20),
                      tooltip: 'Polygon',
                      isSelected: mode is PolygonMode,
                      onPressed: () => setState(() => mode = PolygonMode()),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: GestureDetector(
                  onPanDown: (data) {
                    Renderable? obj = mode.start(Vector2(data.localPosition.dx.toInt(), data.localPosition.dy.toInt()));

                    if (obj != null) {
                      objects.add(obj);
                    }

                    _redrawCanvas();
                  },
                  onPanUpdate: (data) {
                    mode.update(Vector2(data.localPosition.dx.toInt(), data.localPosition.dy.toInt()));
                    _redrawCanvas();
                  },
                  onPanEnd: (data) {
                    mode.end(Vector2(data.localPosition.dx.toInt(), data.localPosition.dy.toInt()));
                    _redrawCanvas();
                  },
                  onTapUp: (data) {
                    mode.end(Vector2(data.localPosition.dx.toInt(), data.localPosition.dy.toInt()));
                    _redrawCanvas();
                  },
                  child: MouseRegion(
                    onHover: (data) {
                      mode.update(Vector2(data.localPosition.dx.toInt(), data.localPosition.dy.toInt()));
                      _redrawCanvas();
                    },
                    child: Container(
                      width: width.toDouble(),
                      height: height.toDouble(),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: renderImage == null
                          ? const Center(child: CircularProgressIndicator())
                          : RawImage(image: renderImage),
                    )
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
