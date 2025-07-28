// ignore_for_file: unused_import, prefer_const_constructors

import 'package:aplikasi_tugasakhir_presensi/halamanfitur/cuti_hariini.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/daftar_karyawan.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/fingerprint_auth.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/dasboard_screen.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/login_screen.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/register_screen.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/onboarding_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  runApp(MyApp()); // ✅ Panggil yang ini
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(), // ← Awal aplikasi
      routes: {
        '/daftar_karyawan': (context) => DaftarKaryawan(),
        '/cuti_hariini': (context) => CutiHariPage(),
        '/dashboard': (context) => DashboardPage(),
        '/welcome': (context) => WelcomeScreen(),
        '/register': (context) => Register(),
        '/login': (context) => LoginScreen(),
        '/fingerprint': (context) => FingerprintAuthPage(),
      },
    );
  }
}
