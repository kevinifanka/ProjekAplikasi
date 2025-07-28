// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/login_screen.dart';

class FingerprintAuthPage extends StatefulWidget {
  const FingerprintAuthPage({Key? key}) : super(key: key);

  @override
  State<FingerprintAuthPage> createState() => _FingerprintAuthPageState();
}

class _FingerprintAuthPageState extends State<FingerprintAuthPage> {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk masuk',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
    }

    if (authenticated) {
      Navigator.pushReplacementNamed(context, '/dashboard'); // langsung ke dashboard
    } else {
      // Jika gagal atau user batal, arahkan ke login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
