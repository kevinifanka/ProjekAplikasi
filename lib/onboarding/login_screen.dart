import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Email dan Password harus diisi!");
      return;
    }

    // TODO: proses login
    _showMessage("Login berhasil!");
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  Future<void> _startFingerprintAuth() async {
    final auth = LocalAuthentication();
    bool canCheck = await auth.canCheckBiometrics;

    if (!canCheck) {
      _showMessage("Fingerprint tidak tersedia");
      return;
    }

    try {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk login',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        Navigator.pushReplacementNamed(context, '/fingerprint');
      }
    } catch (e) {
      debugPrint("Error auth: $e");
      _showMessage("Terjadi kesalahan otentikasi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.login, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 24),

              const Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Masukkan email dan password untuk melanjutkan.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@mail.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Masuk', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _startFingerprintAuth,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: const Icon(Icons.fingerprint, size: 28, color: Colors.black87),
                  )
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("atau"),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Login dengan Google
                },
                icon: Image.asset('images/google.png', width: 20),
                label: const Text("Masuk Dengan Google"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun?"),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        'Daftar Sekarang',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
