import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/login_screen.dart';
import 'package:aplikasi_tugasakhir_presensi/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? email;
  String? imagePath;
  String? userId;
  bool isVerified = false;
  bool isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserDataRealtime(); // Ambil data user secara realtime
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
  }

  // 🔹 Ambil data user secara realtime dari Firestore
  Future<void> _loadUserDataRealtime() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId');
    final firebaseUser = _firebaseService.currentUser;

    // Gunakan userId dari SharedPreferences atau Firebase Auth
    userId = currentUserId ?? firebaseUser?.uid;

    if (userId == null) {
      setState(() {
        isLoading = false;
        name = 'Pengguna';
        email = '';
      });
      return;
    }

    // Set data awal dari SharedPreferences
    setState(() {
      name = prefs.getString('name') ?? 'Pengguna';
      email = prefs.getString('email') ?? firebaseUser?.email ?? '';
      imagePath = prefs.getString('profile_image');
      isVerified = prefs.getBool('isVerified') ?? true;
      isLoading = false;
    });

    // Listen perubahan data user dari Firestore secara realtime
    _userDataSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists && mounted) {
        final userData = snapshot.data();
        final updatedName = userData?['nama'] ?? name ?? 'Pengguna';
        final updatedEmail = userData?['email'] ?? email ?? '';
        
        // Update SharedPreferences juga
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', updatedName);
        await prefs.setString('email', updatedEmail);
        
        if (mounted) {
          setState(() {
            name = updatedName;
            email = updatedEmail;
          });
        }
      }
    }, onError: (error) {
      print('Error listening to user data: $error');
      // Fallback ke SharedPreferences jika error
      if (mounted) {
        _loadUserDataFromPrefs();
      }
    });
  }

  // 🔹 Fallback: Ambil data dari SharedPreferences
  Future<void> _loadUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUser = _firebaseService.currentUser;
    
    setState(() {
      name = prefs.getString('name') ?? firebaseUser?.email?.split('@')[0] ?? 'Pengguna';
      email = prefs.getString('email') ?? firebaseUser?.email ?? '';
      imagePath = prefs.getString('profile_image');
      isVerified = prefs.getBool('isVerified') ?? true;
      isLoading = false;
    });
  }

  // 🔹 Fungsi ambil gambar dari kamera / galeri
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    
    if (pickedImage != null && userId != null) {
      try {
        // Upload foto ke Firebase Storage
        final photoUrl = await _firebaseService.uploadPhoto(
          filePath: pickedImage.path,
          folder: 'profile_images',
          userId: userId!,
        );

        // Update foto di Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'photoUrl': photoUrl});

        // Simpan juga ke SharedPreferences untuk akses cepat
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image', pickedImage.path);
        await prefs.setString('profile_image_url', photoUrl);
        
        if (mounted) {
          setState(() {
            imagePath = pickedImage.path;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil diupdate'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Jika upload gagal, simpan lokal saja
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image', pickedImage.path);
        
        if (mounted) {
          setState(() {
            imagePath = pickedImage.path;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto disimpan lokal. Error upload: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  // 🔹 Pilihan sumber gambar
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.blue),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Logout user dan hapus data
  Future<void> _logout() async {
    try {
      // Logout dari Firebase
      final firebaseService = FirebaseService();
      await firebaseService.signOut();
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (!mounted) return;
      
      // Redirect ke login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saat logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfileImage() {
    if (isLoading) {
      return const SizedBox(
        width: 120,
        height: 120,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    }

    // Gunakan local image jika ada
    if (imagePath != null) {
      return ClipOval(
        child: Image.file(
          File(imagePath!),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    // Default icon
    return const Icon(Icons.person, size: 60, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 30,
                  bottom: 40,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: ClipOval(child: _buildProfileImage()),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name ?? 'Memuat...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Color(0xFF10B981), size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Verified account',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.power_settings_new,
                            size: 28,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
