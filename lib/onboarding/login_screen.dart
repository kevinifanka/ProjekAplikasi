import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:aplikasi_tugasakhir_presensi/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Email dan Password harus diisi!", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Login dengan Firebase
      final credential = await _firebaseService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        // Ambil data user dari Firestore
        final userData = await _firebaseService.getUserData(credential!.user!.uid);
        
        // Simpan data user ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', credential.user!.uid);
        await prefs.setString('email', email);
        await prefs.setString('name', userData?['nama'] ?? email.split('@')[0]);
        await prefs.setString('departemen', userData?['departemen'] ?? userData?['position'] ?? 'Karyawan');
        await prefs.setBool('isLoggedIn', true);

        if (mounted) {
          _showMessage("Login berhasil!", isError: false);
          // Redirect ke dashboard setelah 1 detik
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
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
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      debugPrint("Error auth: $e");
      _showMessage("Terjadi kesalahan otentikasi");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.03),

                      // Title
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: screenWidth * 0.09,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      SizedBox(height: screenHeight * 0.04),

                      // Email Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: screenWidth * 0.04),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: screenWidth * 0.04,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.045,
                              vertical: screenHeight * 0.02,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(fontSize: screenWidth * 0.04),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: screenWidth * 0.04,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.045,
                              vertical: screenHeight * 0.02,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[600],
                                size: screenWidth * 0.055,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),

                      // Forget Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Forgot password
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.005,
                              horizontal: 0,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forget Password?',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Login Button with Fingerprint
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Log In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: _startFingerprintAuth,
                              icon: Icon(
                                Icons.fingerprint,
                                size: screenWidth * 0.07,
                                color: Colors.black87,
                              ),
                              padding: EdgeInsets.all(screenWidth * 0.035),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Sign Up Link
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.025,
                      bottom: screenHeight * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have account? ",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: screenWidth * 0.036,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: const Color(0xFF2563EB),
                              fontSize: screenWidth * 0.036,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}