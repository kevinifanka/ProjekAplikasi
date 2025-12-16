import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service untuk mengelola operasi Firebase
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ========== AUTHENTICATION ==========
  
  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream untuk listen perubahan auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login dengan email dan password
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  /// Register dengan email dan password
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String nama,
    String? departemen,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan data user ke Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'nama': nama,
          'email': email,
          'departemen': departemen ?? 'Karyawan',
          'position': departemen ?? 'Karyawan', // untuk kompatibilitas
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'employee', // default role
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Handle Firebase Auth Exception
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'user-not-found':
        return 'Email tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }

  // ========== FIRESTORE ==========

  /// Simpan data presensi
  Future<void> saveAttendance({
    required String userId,
    required String employeeName,
    required String position,
    required bool isClockIn,
    required String address,
    String? photoUrl,
    String? note,
    String locationType = 'WFO',
  }) async {
    try {
      await _firestore.collection('attendance').add({
        'userId': userId,
        'employeeName': employeeName,
        'position': position,
        'isClockIn': isClockIn,
        'timestamp': FieldValue.serverTimestamp(),
        'address': address,
        'photoUrl': photoUrl,
        'note': note,
        'locationType': locationType,
      });
    } catch (e) {
      throw 'Gagal menyimpan data presensi: $e';
    }
  }

  /// Ambil data presensi user
  Stream<QuerySnapshot> getAttendanceRecords(String userId) {
    return _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Simpan permintaan cuti
  Future<void> saveLeaveRequest({
    required String userId,
    required String employeeName,
    required String jenisCuti,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required int jumlahHari,
    required String alasan,
    List<String>? attachmentUrls,
  }) async {
    try {
      await _firestore.collection('leave_requests').add({
        'userId': userId,
        'employeeName': employeeName,
        'jenisCuti': jenisCuti,
        'tanggalMulai': Timestamp.fromDate(tanggalMulai),
        'tanggalSelesai': Timestamp.fromDate(tanggalSelesai),
        'jumlahHari': jumlahHari,
        'alasan': alasan,
        'attachmentUrls': attachmentUrls ?? [],
        'status': 'Menunggu',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal menyimpan permintaan cuti: $e';
    }
  }

  /// Simpan permintaan gaji
  Future<void> saveSalaryRequest({
    required String userId,
    required String employeeName,
    required DateTime periode,
    required int jumlahGaji,
    required String metodePembayaran,
    String? bank,
    String? nomorRekening,
    String? namaRekening,
    required String alasan,
    List<String>? attachmentUrls,
  }) async {
    try {
      await _firestore.collection('salary_requests').add({
        'userId': userId,
        'employeeName': employeeName,
        'periode': Timestamp.fromDate(periode),
        'jumlahGaji': jumlahGaji,
        'metodePembayaran': metodePembayaran,
        'bank': bank,
        'nomorRekening': nomorRekening,
        'namaRekening': namaRekening,
        'alasan': alasan,
        'attachmentUrls': attachmentUrls ?? [],
        'status': 'Menunggu',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal menyimpan permintaan gaji: $e';
    }
  }

  /// Ambil data karyawan
  Stream<QuerySnapshot> getEmployees() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .snapshots();
  }

  /// Ambil data user dari Firestore berdasarkan userId
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw 'Gagal mengambil data user: $e';
    }
  }

  // ========== STORAGE ==========

  /// Upload foto ke Firebase Storage
  Future<String> uploadPhoto({
    required String filePath,
    required String folder,
    required String userId,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('$folder/$userId/$fileName');
      
      await ref.putFile(File(filePath));
      final url = await ref.getDownloadURL();
      
      return url;
    } catch (e) {
      throw 'Gagal mengupload foto: $e';
    }
  }

  /// Upload multiple files
  Future<List<String>> uploadMultipleFiles({
    required List<String> filePaths,
    required String folder,
    required String userId,
  }) async {
    try {
      final List<String> urls = [];
      for (final filePath in filePaths) {
        final url = await uploadPhoto(
          filePath: filePath,
          folder: folder,
          userId: userId,
        );
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw 'Gagal mengupload file: $e';
    }
  }
}

