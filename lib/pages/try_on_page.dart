import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:orzulab/pages/home_page.dart'; // StyleItem uchun
import 'package:permission_handler/permission_handler.dart';

class TryOnPage extends StatefulWidget {
  final StyleItem item;

  const TryOnPage({Key? key, required this.item}) : super(key: key);

  @override
  State<TryOnPage> createState() => _TryOnPageState();
}

class _TryOnPageState extends State<TryOnPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isPlatformSupported = false;

  @override
  void initState() {
    super.initState();
    // Platformani tekshiramiz. Veb-sayt emasligini va Android yoki iOS ekanligini tekshiramiz.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      setState(() {
        _isPlatformSupported = true;
      });
      _initializeCamera();
    } else {
      setState(() {
        _isPlatformSupported = false;
      });
    }
  }

  Future<void> _initializeCamera() async {
    // Kameraga ruxsat so'raymiz
    final status = await Permission.camera.request();
    if (status.isGranted) {
      // Mavjud kameralar ro'yxatini olamiz
      _cameras = await availableCameras();

      // Agar kameralar mavjud bo'lsa, old kamerani tanlaymiz
      if (_cameras != null && _cameras!.isNotEmpty) {
        CameraDescription selectedCamera;
        try {
          selectedCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
          );
        } catch (e) {
          // Agar old kamera topilmasa, birinchi mavjud kamerani ishlatamiz
          selectedCamera = _cameras!.first;
        }

        await _initializeController(selectedCamera);
      }
    } else {
      debugPrint("Kameradan foydalanishga ruxsat berilmadi.");
    }
  }

  Future<void> _initializeController(CameraDescription cameraDescription) async {
    // Eski kontrollerni tozalaymiz
    await _cameraController?.dispose();

    // Yangi kontroller yaratamiz
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Kamerani ishga tushirishda xatolik: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Agar platforma qo'llab-quvvatlanmasa, boshqa UI ko'rsatamiz
    if (!_isPlatformSupported) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Try On: ${widget.item.title}'),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        body: _buildUnsupportedPlatformView(),
      );
    }

    // Agar platforma qo'llab-quvvatlansa (Android/iOS), kamera bilan ishlaydigan UI ko'rsatamiz
    return Scaffold(
      appBar: AppBar(
        title: Text('Try On: ${widget.item.title}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      extendBodyBehindAppBar: true, // AppBar'ni shaffof qilish uchun
      body: _buildCameraView(),
    );
  }

  /// Kamera ko'rinishini yasaydigan vidjet
  Widget _buildCameraView() {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        // Mahsulot rasmini kamera ustiga joylash
        Positioned.fill(
          child: Opacity(
            opacity: 0.7, // Rasm shaffofligi
            child: Image.asset(
              widget.item.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  /// Qo'llab-quvvatlanmaydigan platformalar uchun UI
  Widget _buildUnsupportedPlatformView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Virtual kiyib ko\'rish bu qurilmada mavjud emas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Image.asset(widget.item.imageUrl, height: 250),
        ],
      ),
    );
  }
}
