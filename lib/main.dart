// ignore_for_file: unused_import, prefer_const_constructors

import 'package:aplikasi_tugasakhir_presensi/halamanfitur/kehadiranmanual.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/daftar_karyawan.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/fingerprint_auth.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/permintaancuti_page.dart';

import 'package:aplikasi_tugasakhir_presensi/onboarding/dasboard_screen.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/login_screen.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/onboarding_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_tugasakhir_presensi/services/firebase_service.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Jika firebase_options.dart belum ada, akan error
    // Jalankan: flutterfire configure
    print('Firebase initialization error: $e');
    print('Jalankan: flutterfire configure');
  }
  
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), // ← Check auth state terlebih dahulu
      routes: {
        '/daftar_karyawan': (context) => DaftarKaryawan(),
        '/permintaancuti': (context) => PengajuanCutiPage(),
        '/dashboard': (context) => DashboardPage(),
        '/register': (context) => Register(),
        '/login': (context) => LoginScreen(),
        '/fingerprint': (context) => FingerprintAuthPage(),
        '/Kehadiran Manual': (context) => KehadiranManualPage(),
      },
    );
  }
}

// Widget untuk check auth state
class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Check Firebase auth state
    final user = _firebaseService.currentUser;
    
    // Check SharedPreferences untuk login status
    final prefs = await SharedPreferences.getInstance();
    final isLoggedInPrefs = prefs.getBool('isLoggedIn') ?? false;
    
    // Jika ada user di Firebase dan SharedPreferences set true, berarti sudah login
    if (user != null && isLoggedInPrefs) {
      // Pastikan data user ada di SharedPreferences
      final name = prefs.getString('name');
      if (name == null) {
        // Ambil data user dari Firestore jika belum ada di SharedPreferences
        try {
          final userData = await _firebaseService.getUserData(user.uid);
          if (userData != null) {
            await prefs.setString('name', userData['nama'] ?? user.email?.split('@')[0] ?? 'Pengguna');
            await prefs.setString('email', user.email ?? '');
            await prefs.setString('userId', user.uid);
          } else {
            // Jika data tidak ada di Firestore, gunakan email sebagai nama
            await prefs.setString('name', user.email?.split('@')[0] ?? 'Pengguna');
            await prefs.setString('email', user.email ?? '');
            await prefs.setString('userId', user.uid);
          }
        } catch (e) {
          print('Error loading user data: $e');
          // Fallback ke email jika error
          await prefs.setString('name', user.email?.split('@')[0] ?? 'Pengguna');
          await prefs.setString('email', user.email ?? '');
          await prefs.setString('userId', user.uid);
        }
      }
      
      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
      });
    } else {
      // Jika belum login, clear SharedPreferences dan redirect ke onboarding
      await prefs.setBool('isLoggedIn', false);
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Jika sudah login, langsung ke dashboard
    // Jika belum login, ke onboarding (yang akan redirect ke register)
    return _isLoggedIn ? DashboardPage() : OnboardingScreen();
  }
}
