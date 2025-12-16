import 'dart:async';
import 'dart:math' as math;
import 'dart:io' show Directory, File, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/ClockOutResultPage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/dashed_circle_painter.dart';

class ClockInPage extends StatefulWidget {
  @override
  _ClockInPageState createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  bool _isCapturing = false;
  double? _smileProbability;
  String _address = 'Mendeteksi lokasi...';
  Timer? _timer;
  int _start = 60;
  String _currentTime = '';
  bool _mounted = true;
  late AnimationController _rotationController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUsingImagePicker = false;
  XFile? _selectedImage;

  Color _circleColor = Colors.red;
  bool _isClockedIn = false;
  static const double _smileThreshold = 0.70;

  @override
  void initState() {
    super.initState();
    _loadClockStatus();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true, // Penting untuk deteksi senyum
        enableLandmarks: true,
        enableTracking: true,
        minFaceSize: 0.1, // Lebih kecil untuk deteksi lebih sensitif
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

  Future<void> _loadClockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isClockedIn = prefs.getBool('isClockedIn') ?? false;
    if (_mounted) {
      setState(() {
        _isClockedIn = isClockedIn;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh status ketika halaman muncul kembali
    _loadClockStatus();
  }

  void _updateTime() {
    final now = DateTime.now();
    if (!_mounted) return;
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
    });
  }

  String _formatTimer(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _initPermissions() async {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Untuk desktop platforms, coba gunakan camera plugin dulu
      try {
        await _initCamera();
        await _getLocation();
      } catch (e) {
        // Jika camera plugin gagal, gunakan image picker sebagai fallback
        setState(() {
          _isUsingImagePicker = true;
          _address = 'Gunakan tombol "Pilih Foto" untuk mengambil gambar dari kamera laptop';
        });
        await _getLocation();
      }
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
        if (_isDetecting || _isCapturing) return;
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

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        
        // Simulasi deteksi wajah untuk image picker
        await _simulateFaceDetection();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _simulateFaceDetection() async {
    // Simulasi deteksi wajah untuk image picker
    setState(() {
      _smileProbability = 0.85; // Simulasi senyum yang baik
      _circleColor = Colors.green;
    });
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) {
      return;
    }

    final currentSmile = _smileProbability ?? 0.0;
    final bool isSmileAccepted = currentSmile >= _smileThreshold;
    if (!isSmileAccepted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Wajah Anda tidak tersenyum, mohon tersenyum lebar lalu ambil presensi kembali.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }

    // Cek lokasi
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      currentPosition = null;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      String photoPath;
      
      if (_isUsingImagePicker) {
        // Jika menggunakan image picker, ambil foto dari kamera
        if (_selectedImage == null) {
          await _pickImageFromCamera();
          if (_selectedImage == null) {
            setState(() {
              _isCapturing = false;
            });
            return;
          }
        }
        photoPath = _selectedImage!.path;
      } else {
        // Jika menggunakan camera controller
        if (_cameraController == null || !_cameraController!.value.isInitialized) {
          setState(() {
            _isCapturing = false;
          });
          return;
        }
        
        await _cameraController!.stopImageStream();
        final XFile photo = await _cameraController!.takePicture();
        photoPath = photo.path;
      }

      await _savePhotoWithCustomName(photoPath);

      if (mounted) {
        // Tentukan apakah ini clock in atau clock out berdasarkan status saat ini
        final isClockIn = !_isClockedIn;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClockOutResultPage(
              capturedImagePath: photoPath,
              userPosition: currentPosition,
              userAddress: _address,
              isClockIn: isClockIn,
              isSmileAccepted: isSmileAccepted,
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _savePhotoWithCustomName(String originalPath) async {
    try {
      if (kIsWeb) return;

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'clockin_${timestamp}.jpg';

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final clockInDir = Directory('${directory.path}/ClockInPhotos');
        if (!await clockInDir.exists()) {
          await clockInDir.create(recursive: true);
        }

        final newPath = '${clockInDir.path}/$fileName';
        final originalFile = File(originalPath);
        
        if (await originalFile.exists()) {
          await originalFile.copy(newPath);
          print('Foto disimpan di: $newPath');
        }
      }
    } catch (e) {
      print('Error saving photo: $e');
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

      if (faces.isNotEmpty) {
        final face = faces[0];
        // Cek ukuran wajah minimal
        if (face.boundingBox.width > 50 && face.boundingBox.height > 50) {
          if (!_mounted) return;
          setState(() {
            // Ambil smilingProbability jika tersedia, jika tidak set ke 0
            _smileProbability = face.smilingProbability ?? 0.0;
            
            // Threshold yang lebih rendah untuk deteksi yang lebih sensitif
            if (_smileProbability! >= 0.70) {
              // Senyum lebar/baik
              _circleColor = Colors.green;
            } else if (_smileProbability! >= 0.50) {
              // Senyum sedang
              _circleColor = Colors.orange;
            } else if (_smileProbability! >= 0.30) {
              // Senyum kecil/tidak jelas
              _circleColor = Colors.yellow;
            } else if (_smileProbability! > 0.0) {
              // Wajah terdeteksi tapi tidak tersenyum
              _circleColor = Colors.orange; // Orange untuk wajah terdeteksi tapi tidak tersenyum
            } else {
              // Wajah terdeteksi tapi tidak ada data senyum
              _circleColor = Colors.yellow; // Kuning untuk wajah terdeteksi
            }
          });
        } else {
          // Wajah terlalu kecil
          if (!_mounted) return;
          setState(() {
            _smileProbability = null;
            _circleColor = Colors.red;
          });
        }
      } else {
        // Tidak ada wajah terdeteksi
        if (!_mounted) return;
        setState(() {
          _smileProbability = null;
          _circleColor = Colors.red;
        });
      }
    } catch (e) {}
  }

  Widget _buildImagePickerView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: _selectedImage != null
          ? Image.file(
              File(_selectedImage!.path),
              fit: BoxFit.cover,
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 80,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Kamera Laptop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tekan tombol "Pilih Foto" untuk mengambil gambar',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
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
          _isUsingImagePicker
              ? _buildImagePickerView()
              : (_cameraController != null && _cameraController!.value.isInitialized
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
                    )),
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
                            _formatTimer(_start),
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
                    _smileProbability != null && _smileProbability! >= 0.70
                        ? 'Tersenyum sempurna! 😊' 
                        : _smileProbability != null && _smileProbability! >= 0.50
                        ? 'Senyum lebih lebar lagi! 😐'
                        : _smileProbability != null && _smileProbability! > 0.0
                        ? 'Wajah terdeteksi, tersenyum lebar! 😊'
                        : _smileProbability != null && _smileProbability! == 0.0
                        ? 'Wajah terdeteksi, tapi tidak tersenyum. Tersenyum lebar! 😊'
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'JAM MASUK: 08:00',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'JAM PULANG: 09:40',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_isUsingImagePicker) ...[
                      ElevatedButton(
                        onPressed: _pickImageFromCamera,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Pilih Foto',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    ElevatedButton(
                      onPressed: _capturePhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        _isClockedIn ? 'Clock Out' : 'Clock In',
                        style: const TextStyle(fontSize: 18),
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
