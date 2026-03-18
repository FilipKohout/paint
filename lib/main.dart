import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paint/config.dart';
import 'package:paint/interfaces/mode.dart';
import 'package:paint/interfaces/renderable.dart';
import 'package:paint/models/eraser.dart';
import 'package:paint/models/pixel.dart';
import 'package:paint/models/selectionBox.dart';
import 'package:paint/models/selectionPointsRender.dart';
import 'package:paint/models/vector2.dart';
import 'package:paint/modes/eraseMode.dart';
import 'package:paint/modes/fillMode.dart';
import 'package:paint/modes/polygonMode.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:paint/modes/selectNodeMode.dart';

import 'models/color.dart';
import 'models/line.dart';
import 'modes/circleMode.dart';
import 'modes/lineMode.dart';
import 'modes/rectangleMode.dart';
import 'modes/selectObjectMode.dart';
import 'modes/squareMode.dart';

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
    late Uint8List bgPixels;
    late Uint8List fgPixels;
    late List<Renderable> objects = [];
    late List<Pixel> usedPixels = [];
    late Mode mode = LineMode();

    ui.Image? bgImage;
    ui.Image? fgImage;

    Color pickerColor = const Color(0xff000000);
    Color currentColor = const Color(0xff000000);
    LineStyle currentStyle = LineStyle.solid;
    int currentThickness = 5;

    void changeColor(Color color) {
      setState(() => pickerColor = color);
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

    void _fillBgWhite() {
      for (int i = 0; i < bgPixels.length; i += 4) {
        bgPixels[i] = 255; bgPixels[i + 1] = 255; bgPixels[i + 2] = 255; bgPixels[i + 3] = 255;
      }
    }

    void _clearFg() {
      for (int i = 0; i < fgPixels.length; i += 4) {
        fgPixels[i] = 0; fgPixels[i + 1] = 0; fgPixels[i + 2] = 0; fgPixels[i + 3] = 0;
      }
    }

    void _setPixelTo(Uint8List targetPixels, Pixel p) {
      if (p.position.x >= 0 && p.position.x < Config.width && p.position.y >= 0 && p.position.y < Config.height) {
        int index = (p.position.y * Config.width + p.position.x) * 4;

        int oldA = targetPixels[index + 3];
        int newA = p.color.a.toInt();

        targetPixels[index] = (p.color.r.toInt() * newA + targetPixels[index] * (255 - newA)) ~/ 255;
        targetPixels[index + 1] = (p.color.g.toInt() * newA + targetPixels[index + 1] * (255 - newA)) ~/ 255;
        targetPixels[index + 2] = (p.color.b.toInt() * newA + targetPixels[index + 2] * (255 - newA)) ~/ 255;
        targetPixels[index + 3] = p.color.a.toInt();
      }
    }

    bool _checkDelete() {
      List<Renderable> toRemove = [];

       for (Renderable obj in objects) {
        if (obj.deleted) toRemove.add(obj);
      }

      for (Renderable obj in toRemove) {
        objects.remove(obj);
      }

      return toRemove.isNotEmpty;
    }

    void _redrawAll() {
      _fillBgWhite();
      _checkDelete();
      usedPixels.clear();

      for (var object in objects) {
        if (object.foregroundOnly) continue;

        for (Pixel p in object.pixelate()) {
          usedPixels.add(p);
          _setPixelTo(bgPixels, p);
        }
      }
      _updateImages();
      _redrawActiveOnly();
    }

    void _redrawActiveOnly() {
      _clearFg();

      if (objects.isNotEmpty) {
        if (_checkDelete()) {
          _redrawAll();
          return;
        }

        var activeObj = objects.last;

        for (Renderable obj in objects) {
          if (obj == activeObj || obj.foregroundOnly) {
            for (Pixel p in obj.pixelate()) {
              _setPixelTo(fgPixels, p);
            }
          }
        }
      }

      _updateImages();
    }

    Future<void> _updateImages() async {
      ui.decodeImageFromPixels(bgPixels, Config.width, Config.height, ui.PixelFormat.rgba8888, (img) {
        setState(() => bgImage = img);
      });
      ui.decodeImageFromPixels(fgPixels, Config.width, Config.height, ui.PixelFormat.rgba8888, (img) {
        setState(() => fgImage = img);
      });
    }

    bool _onKey(KeyEvent event) {
      mode.onKey(event);
      _redrawActiveOnly();
      return true;
    }

    void _updateMode() {
      mode.color = RGBA(currentColor.r * 255, currentColor.g * 255, currentColor.b * 255, currentColor.a * 255);
      mode.thickness = currentThickness;
      mode.style = currentStyle;

      if (mode is! SelectObjectMode) {
        for (Renderable obj in objects) {
          if (obj is SelectionBox) objects.remove(obj);
        }
      }

      if (mode is! SelectNodeMode) {
        for (Renderable obj in objects) {
          if (obj is SelectionPointsRender) objects.remove(obj);
        }
      }

      if (mode is! EraseMode) {
        for (Renderable obj in objects) {
          if (obj is Eraser) objects.remove(obj);
        }
      }
    }

    @override
    void setState(VoidCallback fn) {
      super.setState(fn);
      _updateMode();
    }

    @override
    void initState() {
      super.initState();
      ServicesBinding.instance.keyboard.addHandler(_onKey);

      bgPixels = Uint8List(Config.width * Config.height * 4);
      fgPixels = Uint8List(Config.width * Config.height * 4);

      _fillBgWhite();
      _clearFg();
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
                          icon: const Icon(Icons.pan_tool, size: 20),
                          tooltip: 'Select Object',
                          isSelected: mode is SelectObjectMode,
                          onPressed: () => setState(() {
                            mode = SelectObjectMode();
                            Renderable? box = mode.start(Vector2(0, 0), usedPixels, objects);

                            if (box != null) objects.add(box);
                            _redrawActiveOnly();
                          }),
                        ),
                        const SizedBox(width: 5),
                        IconButton.filled(
                          icon: const Icon(Icons.pan_tool_alt, size: 20),
                          tooltip: 'Select Node',
                          isSelected: mode is SelectNodeMode,
                          onPressed: () => setState(() {
                            mode = SelectNodeMode();
                            Renderable? box = mode.start(Vector2(0, 0), usedPixels, objects);

                            if (box != null) objects.add(box);
                            _redrawActiveOnly();
                          }),
                        ),
                        const SizedBox(width: 5),
                        IconButton.filled(
                          icon: const Icon(Icons.linear_scale, size: 20),
                          tooltip: 'Line',
                          isSelected: mode is LineMode,
                          onPressed: () => setState(() => mode = LineMode()),
                        ),
                        const SizedBox(width: 5),
                        IconButton.filled(
                          icon: const Icon(Icons.square_outlined, size: 20),
                          tooltip: 'Square',
                          isSelected: mode is SquareMode,
                          onPressed: () => setState(() => mode = SquareMode()),
                        ),
                        const SizedBox(width: 5),
                        IconButton.filled(
                          icon: const Icon(Icons.rectangle_outlined, size: 20),
                          tooltip: 'Rectangle',
                          isSelected: mode is RectangleMode && mode is! SquareMode,
                          onPressed: () => setState(() => mode = RectangleMode()),
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
                        const SizedBox(width: 5),
                        IconButton.filled(
                          icon: const Icon(Icons.format_color_fill, size: 20),
                          tooltip: 'Fill',
                          isSelected: mode is FillMode,
                          onPressed: () => setState(() => mode = FillMode()),
                        ),
                        const SizedBox(width: 5),
                        IconButton.filled(
                          icon: const Icon(Icons.cleaning_services_rounded, size: 20),
                          tooltip: 'Erase',
                          isSelected: mode is EraseMode,
                          onPressed: () => setState(() {
                            mode = EraseMode();
                            _updateMode();
                            Renderable? box = mode.start(Vector2(-50, -50), usedPixels, objects);
                            mode.end(Vector2(-50, -50));

                            if (box != null) objects.add(box);
                            _redrawActiveOnly();
                          }),
                        ),
                        const VerticalDivider(color: Colors.grey, thickness: 1, width: 20, indent: 10, endIndent: 10),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.delete, size: 20),
                          tooltip: 'Clear',
                          onPressed: () {
                            setState(() {
                              objects.clear();
                              _redrawAll();
                              mode = SelectObjectMode();

                              Renderable? box = mode.start(Vector2(0, 0), usedPixels, objects);
                              if (box != null) objects.add(box);
                              _redrawActiveOnly();
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
                    Renderable? obj = mode.start(Vector2(data.localPosition.dx.toInt(), data.localPosition.dy.toInt()), usedPixels, objects);

                    if (obj != null && !objects.contains(obj)) {
                      objects.add(obj);
                    }

                    _redrawActiveOnly();
                  },
                  onPanUpdate: (data) {
                    mode.update(Vector2(data.localPosition.dx.toInt(), data.localPosition.dy.toInt()));
                    _redrawActiveOnly();
                  },
                  onPanEnd: (data) {
                    mode.end(Vector2(data.localPosition.dx.toInt(), data.localPosition.dy.toInt()));
                    _redrawAll();
                  },
                  onTapUp: (data) {
                    mode.end(Vector2(data.localPosition.dx.toInt(), data.localPosition.dy.toInt()));
                    _redrawAll();
                  },
                  child: MouseRegion(
                    onHover: (data) {
                      mode.update(Vector2(data.localPosition.dx.toInt(), data.localPosition.dy.toInt()));
                      _redrawActiveOnly();
                    },
                    cursor: SystemMouseCursors.precise,
                    child: Container(
                      width: Config.width.toDouble(),
                      height: Config.height.toDouble(),
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3)],
                      ),
                      child: Stack(
                        children: [
                          if (bgImage != null)
                            RawImage(image: bgImage),
                          if (fgImage != null)
                            RawImage(image: fgImage),
                        ],
                      ),
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
