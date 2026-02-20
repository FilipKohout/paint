import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:paint/interfaces/renderize.dart';
import 'package:paint/models/pixel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  final int sirka = 800;
  final int vyska = 600;

  late Uint8List pixels;
  late List<Renderable> objects = [];

  ui.Image? renderImage;

  @override
  void initState() {
    super.initState();
    pixels = Uint8List(sirka * vyska * 4);
    _clearCanvas();
  }

  void _clearCanvas() {
    for (int i = 0; i < pixels.length; i += 4) {
      pixels[i] = 255;
      pixels[i + 1] = 255;
      pixels[i + 2] = 255;
      pixels[i + 3] = 255;
    }
    _updateCanvas();
  }

  void setPixel(Pixel p) {
    if (p.position.x >= 0 && p.position.x < sirka && p.position.y >= 0 && p.position.y < vyska) {
      int index = (p.position.y * sirka + p.position.x) * 4;
      pixels[index] = p.color.r;
      pixels[index + 1] = p.color.g;
      pixels[index + 2] = p.color.b;
      pixels[index + 3] = 255;
    }
  }

  Future<void> _updateCanvas() async {
    ui.decodeImageFromPixels(pixels, sirka, vyska, ui.PixelFormat.rgba8888, (ui.Image img,) {
      setState(() {
        renderImage = img;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 80,
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.linear_scale_rounded, size: 30),
                    tooltip: 'Štětec',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: GestureDetector(
                onPanDown: (data) {

                  _updateCanvas();
                },
                onPanUpdate: (data) {

                  _updateCanvas();
                },
                child: Container(
                  width: sirka.toDouble(),
                  height: vyska.toDouble(),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: renderImage == null
                      ? const Center(child: CircularProgressIndicator())
                      : RawImage(image: renderImage),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
