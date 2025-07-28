// ignore_for_file: unused_import

import 'dart:async';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/clockin_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';

class FaceScanPage extends StatefulWidget {
  const FaceScanPage({super.key});

  @override
  State<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  late String _jam;
  late String _hariTanggal;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final jam = DateFormat.Hms().format(now).replaceAll('.', ':');
    final hariTanggal = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    setState(() {
      _jam = jam;
      _hariTanggal = hariTanggal;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _handlePresence() {
    Navigator.push(
      context,
       MaterialPageRoute(builder: (context) =>  ClockInPage()),
      );
  }

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPreviewPage(camera: firstCamera),
        ),
      );
    } catch (e) {
      debugPrint('Error membuka kamera: $e');
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _jam,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$_hariTanggal WIB',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('images/Saya.png'),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "📋 Log Kehadiran",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Memuat data...",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "📅 Regular Office",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "08:00 - 17:00 WIB",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _handlePresence,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.watch_later_outlined,
                                  color: Colors.black87),
                              SizedBox(width: 8),
                              Text(
                                "Clock In / Out Sekarang",
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CameraPreviewPage extends StatefulWidget {
  final CameraDescription camera;

  const CameraPreviewPage({super.key, required this.camera});

  @override
  State<CameraPreviewPage> createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<CameraPreviewPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presensi Kamera')),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
