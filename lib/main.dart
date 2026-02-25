import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paint/interfaces/mode.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/vector2.dart';
import 'package:paint/modes/polygonMode.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'models/color.dart';
import 'models/line.dart';
import 'modes/circleMode.dart';
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

    Color pickerColor = const Color(0xff000000);
    Color currentColor = const Color(0xff000000);
    LineStyle currentStyle = LineStyle.solid;
    int currentThickness = 5;

    void changeColor(Color color) {
      setState(() => pickerColor = color);
    }

    Future<void> updateCanvas() async {
      ui.decodeImageFromPixels(pixels, width, height, ui.PixelFormat.rgba8888, (ui.Image img) {
        setState(() {
          renderImage = img;
        });
      });
    }

    void _openColorPicker() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: changeColor,
                colorPickerWidth: 300,
                pickerAreaHeightPercent: 0.7,
                enableAlpha: true,
                labelTypes: [ColorLabelType.rgb, ColorLabelType.hex],
                displayThumbColor: true,
                paletteType: PaletteType.hsl,
                pickerAreaBorderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                )
              ),
            ),
            actions: <Widget>[
              FilledButton(
                child: const Text("Done"),
                onPressed: () {
                  setState(() {
                    currentColor = pickerColor;
                    _updateMode();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void _openThicknessPicker() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(10, (index) => index + 1).map((thickness) {
                  return ListTile(
                    title: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        color: Colors.black,
                      ),
                      child: SizedBox(
                        height: thickness.toDouble(),
                        width: double.infinity,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        currentThickness = thickness;
                        _updateMode();
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    }

    void _openStylePicker() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: LineStyle.values.map((style) {
                  return ListTile(
                    title: Text(style.toString().split('.').last.toUpperCase()),
                    onTap: () {
                      setState(() {
                        currentStyle = style;
                        _updateMode();
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    }

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

      updateCanvas();
    }

    void _setPixel(Pixel p) {
      if (p.position.x >= 0 && p.position.x < width && p.position.y >= 0 && p.position.y < height) {
        int index = (p.position.y * width + p.position.x) * 4;
        pixels[index] = p.color.r.toInt();
        pixels[index + 1] = p.color.g.toInt();
        pixels[index + 2] = p.color.b.toInt();
        pixels[index + 3] = p.color.a.toInt();
      }
    }

    bool _onKey(KeyEvent event) {
      mode.onKey(event);
      _redrawCanvas();
      return true;
    }

    void _updateMode() {
      mode.color = RGBA(currentColor.r * 255, currentColor.g * 255, currentColor.b * 255, currentColor.a * 255);
      mode.thickness = currentThickness;
      mode.style = currentStyle;
    }

    @override
    void didUpdateWidget(oldWidget) {
      super.didUpdateWidget(oldWidget);
      _updateMode();
    }

    @override
    void initState() {
      super.initState();
      ServicesBinding.instance.keyboard.addHandler(_onKey);

      pixels = Uint8List(width * height * 4);
      _fillCanvasWhite();
      _updateMode();
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton.filled(
                          icon: const Icon(Icons.linear_scale, size: 20),
                          tooltip: 'Line',
                          isSelected: mode is LineMode,
                          onPressed: () => setState(() => mode = LineMode()),
                        ),
                        const SizedBox(width: 5),
                        IconButton.filled(
                          icon: const Icon(Icons.polyline, size: 20),
                          tooltip: 'Polygon',
                          isSelected: mode is PolygonMode,
                          onPressed: () => setState(() => mode = PolygonMode()),
                        ),
                        const SizedBox(width: 5),
                        IconButton.filled(
                          icon: const Icon(Icons.circle_outlined, size: 20),
                          tooltip: 'Circle',
                          isSelected: mode is CircleMode,
                          onPressed: () => setState(() => mode = CircleMode()),
                        ),
                        const VerticalDivider(color: Colors.black54, thickness: 1, width: 20, indent: 10, endIndent: 10),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.delete, size: 20),
                          tooltip: 'Clear',
                          onPressed: () {
                            setState(() {
                              objects.clear();
                              _fillCanvasWhite();
                              updateCanvas();
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.color_lens, size: 20),
                          style: IconButton.styleFrom(backgroundColor: currentColor, foregroundColor: useWhiteForeground(currentColor) ? Colors.white : Colors.black),
                          tooltip: 'Color',
                          onPressed: _openColorPicker,
                        ),
                        const SizedBox(width: 5),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.line_weight, size: 20),
                          tooltip: 'Thickness',
                          onPressed: _openThicknessPicker,
                        ),
                        const SizedBox(width: 5),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.line_style, size: 20),
                          tooltip: 'Style',
                          onPressed: _openStylePicker,
                        ),
                      ],
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
