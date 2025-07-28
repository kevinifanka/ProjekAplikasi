// ignore_for_file: unused_import

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:io' show Directory, File, Platform; // ✅ Tambahkan File untuk menyimpan gambar
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/ClockOutResultPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // ✅ Untuk mendapatkan direktori penyimpanan

class ClockInPage extends StatefulWidget {
  @override
  _ClockInPageState createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  bool _isCapturing = false; // ✅ Status capturing
  double? _smileProbability;
  String _address = 'Mendeteksi lokasi...';
  Timer? _timer;
  int _start = 10;
  String _currentTime = '';
  bool _mounted = true;
  late AnimationController _rotationController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  String? _capturedImagePath; // ✅ Path gambar yang diambil

  Color _circleColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _initPermissions();
    _startCountdown();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  void _updateTime() {
    final now = DateTime.now();
    if (!_mounted) return;
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
    });
  }

  Future<void> _initPermissions() async {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await _initCamera();
      await _getLocation();
    } else {
      final cameraStatus = await Permission.camera.request();
      final locationStatus = await Permission.location.request();

      if (cameraStatus.isGranted && locationStatus.isGranted) {
        await _initCamera();
        await _getLocation();
      } else {
        setState(() {
          _address = 'Izin dibutuhkan untuk kamera dan lokasi.';
        });
      }
    }
  }

  Future<void> _getLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;
      if (!_mounted) return;
      setState(() {
        _address = "${place.street}, ${place.subLocality}, ${place.locality}";
      });
    } catch (e) {
      setState(() {
        _address = kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux
            ? 'Lokasi tidak tersedia (Desktop)'
            : 'Gagal mendapatkan lokasi';
      });
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        if (!_mounted) return;
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        setState(() {
          _address = 'Tidak ada kamera yang tersedia';
        });
        return;
      }

      CameraDescription selectedCamera;
      int frontCameraIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      
      if (frontCameraIndex != -1) {
        selectedCamera = _cameras[frontCameraIndex];
        _selectedCameraIndex = frontCameraIndex;
      } else {
        selectedCamera = _cameras.first;
        _selectedCameraIndex = 0;
      }

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _cameraController!.initialize();

      if (!_mounted) return;

      _cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting || _isCapturing) return; // ✅ Jangan deteksi saat capturing
        _isDetecting = true;

        _detectFaces(image).then((_) {
          Future.delayed(const Duration(milliseconds: 150), () {
            _isDetecting = false;
          });
        });
      });

      setState(() {});
    } catch (e) {
      setState(() {
        _address = 'Kamera gagal diinisialisasi: ${e.toString()}';
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length <= 1) return;
    
    await _cameraController?.dispose();
    
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    
    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    
    await _cameraController!.initialize();
    
    _cameraController!.startImageStream((CameraImage image) {
      if (_isDetecting || _isCapturing) return;
      _isDetecting = true;

      _detectFaces(image).then((_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          _isDetecting = false;
        });
      });
    });
    
    setState(() {});
  }

  // ✅ Fungsi untuk mengambil foto
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Stop image stream sementara untuk mengambil foto
      await _cameraController!.stopImageStream();
      
      // Ambil foto
      final XFile photo = await _cameraController!.takePicture();
      
      // Simpan path gambar
      setState(() {
        _capturedImagePath = photo.path;
      });

      // ✅ Optional: Simpan foto dengan nama yang lebih deskriptif
      await _savePhotoWithCustomName(photo.path);

      // ✅ Navigasi ke halaman hasil setelah berhasil capture
      if (mounted) {
        // Get current position for the result page
        Position? currentPosition;
        try {
          currentPosition = await Geolocator.getCurrentPosition(
            timeLimit: const Duration(seconds: 5),
          );
        } catch (e) {
          // Ignore location error
        }

        // Navigate to result page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClockOutResultPage(
              capturedImagePath: photo.path,
              userPosition: currentPosition,
              userAddress: _address,
            ),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  // ✅ Fungsi untuk menyimpan foto dengan nama custom
  Future<void> _savePhotoWithCustomName(String originalPath) async {
    try {
      if (kIsWeb) {
        // Untuk web, gunakan path asli
        return;
      }

      // Buat nama file dengan timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'clockin_${timestamp}.jpg';

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        // Buat folder khusus untuk foto clock in
        final clockInDir = Directory('${directory.path}/ClockInPhotos');
        if (!await clockInDir.exists()) {
          await clockInDir.create(recursive: true);
        }

        final newPath = '${clockInDir.path}/$fileName';
        final originalFile = File(originalPath);
        
        if (await originalFile.exists()) {
          await originalFile.copy(newPath);
          print('Foto disimpan di: $newPath'); // Untuk debugging
        }
      }
    } catch (e) {
      print('Error saving photo: $e'); // Untuk debugging
    }
  }

  Future<void> _detectFaces(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final camera = _cameraController!.description;
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (imageRotation == null) return;

      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
      if (inputImageFormat == null) return;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty && faces[0].smilingProbability != null) {
        final face = faces[0];
        if (face.boundingBox.width > 50 && face.boundingBox.height > 50) {
          if (!_mounted) return;
          setState(() {
            _smileProbability = face.smilingProbability!;
            
            if (_smileProbability! > 0.85) {
              _circleColor = Colors.green;
            } else if (_smileProbability! > 0.65) {
              _circleColor = Colors.orange;
            } else if (_smileProbability! > 0.45) {
              _circleColor = Colors.yellow;
            } else {
              _circleColor = Colors.red;
            }
          });
        }
      } else {
        if (!_mounted) return;
        setState(() {
          _smileProbability = 0.0;
          _circleColor = Colors.red;
        });
      }
    } catch (e) {
      // Silent error handling
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _cameraController?.dispose();
    _faceDetector.close();
    _timer?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final smilePercentage = _smileProbability != null
        ? "${(_smileProbability! * 100).toStringAsFixed(0)}%"
        : "0%";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _cameraController != null && _cameraController!.value.isInitialized
              ? CameraPreview(_cameraController!)
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Menginisialisasi kamera...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

          // ✅ Overlay saat capturing
          if (_isCapturing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Mengambil foto...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Header Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      if (_cameras.length > 1)
                        IconButton(
                          icon: const Icon(Icons.switch_camera, color: Colors.white, size: 24),
                          onPressed: _switchCamera,
                        ),
                      const Spacer(),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _start.toString().padLeft(2, '0') + ':58',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Smile info and overlay
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(
                  Icons.sentiment_neutral,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  smilePercentage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _smileProbability != null && _smileProbability! > 0.85
                        ? 'Tersenyum sempurna! 😊' 
                        : _smileProbability != null && _smileProbability! > 0.45
                        ? 'Senyum lebih lebar lagi! 😐'
                        : 'Posisikan wajah Anda didalam lingkaran dan tersenyum lebar!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Animated rotating circle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: CustomPaint(
                      painter: DashedCirclePainter(color: _circleColor),
                      size: const Size(220, 220),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Info Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kamis, 17 Jul 2025, $_currentTime WIB',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            kIsWeb ? 'Web' : Platform.operatingSystem,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        // ✅ Indikator status foto
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _capturedImagePath != null 
                                ? Colors.green.withOpacity(0.3)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _capturedImagePath != null ? Icons.check_circle : Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _capturedImagePath != null ? 'Foto tersimpan' : 'network',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ✅ Tombol capture yang dapat diklik
                    GestureDetector(
                      onTap: _isCapturing ? null : _capturePhoto,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isCapturing ? Colors.grey : Colors.white, 
                            width: 3
                          ),
                          color: Colors.transparent,
                        ),
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCapturing ? Colors.grey : Colors.white,
                            ),
                            child: _isCapturing
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 15.0;
    const dashSpace = 8.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (dashWidth + dashSpace) / radius;
      canvas.drawArc(
        Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
        startAngle,
        dashWidth / radius,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}