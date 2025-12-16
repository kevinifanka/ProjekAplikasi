// ignore_for_file: unused_import

import 'package:aplikasi_tugasakhir_presensi/Dashboard%20_Admin/ApprovalDashboard.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/kehadiranmanual.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/lemburpage_screen.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/perubahanshift.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/face_scan_page.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/permintaancuti_page.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/permintaan_gaji_page.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    FaceScanPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: 'Kehadiran'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ✅ Helper untuk item menu (yang bisa diklik)
Widget _buildMenuItem(IconData icon, String label, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    ),
  );
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _userName = 'Pengguna';
  
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? 'Pengguna';
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEEF2F3), Color(0xFFDDEAF6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Foreground content
          Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 22,
                      backgroundImage: AssetImage('images/Group.png'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Text(
                            'Smart Clock In Presensi',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    const Icon(Icons.headset_mic, color: Colors.blue, size: 28),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Menu Grid
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMenuItem(Icons.beach_access, 'Cuti', Colors.red, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  PengajuanCutiPage()),
                    );
                  }),
                  _buildMenuItem(Icons.access_time, 'Lembur', Colors.red, () {
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const PengajuanLemburPage()),
                    );
                  }),
                    _buildMenuItem(Icons.edit_calendar, 'Hadir Manual', Colors.orange, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const KehadiranManualPage()),
                    );
                  }),

                  _buildMenuItem(Icons.swap_horiz, 'PerubahanShift', Colors.orange, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PengajuanPerubahanShiftPage()),
                    );
                  }),
                  _buildMenuItem(Icons.money, 'PermintaanGaji', Colors.green, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PermintaanGajiPage()),
                    );
                  }),
                  _buildMenuItem(Icons.money, 'HRD Admin', Colors.green, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ApprovalDashboard()),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 210),

              // List Section
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: Colors.grey[100],
                        title: const Text('Daftar Karyawan'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.pushNamed(context, '/daftar_karyawan'),
                      ),
                      const SizedBox(height: 12),
                      
              
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
