// ignore_for_file: unused_import

import 'dart:async';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/clockin_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceScanPage extends StatefulWidget {
  const FaceScanPage({super.key});

  @override
  State<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  late String _jam;
  late String _hariTanggal;
  late Timer _timer;
  bool _isClockedIn = false;
  String? _clockInTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadClockStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
      _loadClockStatus(); // Update status setiap detik untuk realtime
    });
  }
  
  Future<void> _loadClockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isClockedIn = prefs.getBool('isClockedIn') ?? false;
    final clockInTime = prefs.getString('clockInTime');
    
    if (mounted) {
      setState(() {
        _isClockedIn = isClockedIn;
        _clockInTime = clockInTime;
      });
    }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh status ketika halaman muncul kembali
    _loadClockStatus();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _handlePresence() async {
    if (_isClockedIn) {
      // Jika sudah clock in, arahkan ke clock out
      // TODO: Implementasi halaman clock out jika berbeda
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClockInPage()),
      );
    } else {
      // Jika belum clock in, arahkan ke clock in
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClockInPage()),
      );
    }
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
                      Text(
                        _isClockedIn ? "Sedang bekerja" : "Memuat data...",
                        style: TextStyle(
                          color: _isClockedIn ? Colors.green[700] : Colors.grey,
                          fontWeight: _isClockedIn ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      if (_isClockedIn && _clockInTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Clock In: ${DateFormat('HH:mm').format(DateTime.parse(_clockInTime!))}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
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
                            color: _isClockedIn ? Colors.orange[100] : Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isClockedIn ? Icons.logout : Icons.watch_later_outlined,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isClockedIn ? "Clock Out" : "Clock In",
                                style: const TextStyle(color: Colors.black87),
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
