import 'package:flutter/material.dart';
import 'package:aplikasi_tugasakhir_presensi/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController departemenController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();
  
  // List departemen yang umum
  final List<String> _departemenOptions = [
    'IT/Technology',
    'HRD',
    'Finance',
    'Marketing',
    'Sales',
    'Operations',
    'Production',
    'Quality Control',
    'Logistics',
    'Customer Service',
    'Management',
    'Lainnya'
  ];
  String? _selectedDepartemen;

  // Validasi format email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _register() async {
    String email = emailController.text.trim();
    String nama = namaController.text.trim();
    String password = passwordController.text.trim();
    String departemen = _selectedDepartemen ?? departemenController.text.trim();

    // Validasi input
    if (email.isEmpty || nama.isEmpty || password.isEmpty) {
      _showMessage("Harap isi semua data", isError: true);
      return;
    }

    // Validasi format email
    if (!_isValidEmail(email)) {
      _showMessage("Format email tidak valid", isError: true);
      return;
    }

    // Validasi panjang password
    if (password.length < 6) {
      _showMessage("Password minimal 6 karakter", isError: true);
      return;
    }

    // Validasi nama tidak boleh kosong setelah trim
    if (nama.length < 2) {
      _showMessage("Nama minimal 2 karakter", isError: true);
      return;
    }

    // Validasi departemen
    if (departemen.isEmpty) {
      _showMessage("Harap pilih atau isi departemen", isError: true);
      return;
    }

    // Validasi terms and conditions
    if (!_agreeToTerms) {
      _showMessage("Anda harus menyetujui Terms of Service dan Privacy Policy", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Registrasi dengan Firebase
      final credential = await _firebaseService.signUpWithEmailPassword(
        email: email,
        password: password,
        nama: nama,
        departemen: departemen,
      );

      if (credential?.user != null) {
        // Simpan data user ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', credential!.user!.uid);
        await prefs.setString('name', nama);
        await prefs.setString('email', email);
        await prefs.setString('departemen', departemen);
        await prefs.setBool('isLoggedIn', true);

        if (mounted) {
          _showMessage("Pendaftaran berhasil!", isError: false);
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
                        'Sign Up',
                        style: TextStyle(
                          fontSize: screenWidth * 0.09,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      SizedBox(height: screenHeight * 0.04),

                      // Name Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: namaController,
                          style: TextStyle(fontSize: screenWidth * 0.04),
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
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

                      // Departemen Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: screenWidth * 0.045,
                                top: screenHeight * 0.015,
                                bottom: screenHeight * 0.005,
                              ),
                              child: Text(
                                'Departemen / Posisi',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDepartemen,
                                hint: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.045,
                                  ),
                                  child: Text(
                                    'Pilih Departemen',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                ),
                                isExpanded: true,
                                icon: Padding(
                                  padding: EdgeInsets.only(
                                    right: screenWidth * 0.045,
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                items: _departemenOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.045,
                                      ),
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedDepartemen = newValue;
                                    if (newValue == 'Lainnya') {
                                      departemenController.clear();
                                    } else {
                                      departemenController.text = newValue ?? '';
                                    }
                                  });
                                },
                              ),
                            ),
                            if (_selectedDepartemen == 'Lainnya') ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.045,
                                  vertical: screenHeight * 0.01,
                                ),
                                child: TextField(
                                  controller: departemenController,
                                  style: TextStyle(fontSize: screenWidth * 0.04),
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan departemen',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
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
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.045,
                                      vertical: screenHeight * 0.015,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),

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
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
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
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
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
                      SizedBox(height: screenHeight * 0.018),

                      // Terms and Conditions Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            child: Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.002),
                              child: Wrap(
                                children: [
                                  Text(
                                    "I'm agree to The ",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: screenWidth * 0.033,
                                      height: 1.3,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Open Terms of Service
                                    },
                                    child: Text(
                                      "Terms of Service",
                                      style: TextStyle(
                                        color: const Color(0xFF2563EB),
                                        fontSize: screenWidth * 0.033,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    " and ",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: screenWidth * 0.033,
                                      height: 1.3,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Open Privacy Policy
                                    },
                                    child: Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                        color: const Color(0xFF2563EB),
                                        fontSize: screenWidth * 0.033,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
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
                                  'Buat Akun',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),

                  // Sign In Link
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.025,
                      bottom: screenHeight * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun? ",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: screenWidth * 0.036,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: Text(
                            'Masuk',
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