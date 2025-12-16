import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PengajuanModel {
  final String id;
  final String nama;
  final String tipe; // Cuti, Lembur, Hadir Manual, Perubahan Shift
  final String tanggal;
  final String alasan;
  final String status; // Menunggu, Disetujui, Ditolak
  final Map<String, dynamic>? detail; // Detail tambahan untuk setiap tipe

  PengajuanModel({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.tanggal,
    required this.alasan,
    this.status = "Menunggu",
    this.detail,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe,
      'tanggal': tanggal,
      'alasan': alasan,
      'status': status,
      'detail': detail,
    };
  }

  factory PengajuanModel.fromJson(Map<String, dynamic> json) {
    return PengajuanModel(
      id: json['id'],
      nama: json['nama'],
      tipe: json['tipe'],
      tanggal: json['tanggal'],
      alasan: json['alasan'],
      status: json['status'] ?? 'Menunggu',
      detail: json['detail'],
    );
  }
}

class PengajuanService extends ChangeNotifier {
  static final PengajuanService _instance = PengajuanService._internal();
  factory PengajuanService() => _instance;
  PengajuanService._internal();

  List<PengajuanModel> _pengajuanList = [];
  static const String _storageKey = 'pengajuan_list';

  List<PengajuanModel> get pengajuanList => List.unmodifiable(_pengajuanList);

  // Ambil pengajuan yang masih menunggu
  List<PengajuanModel> get pendingPengajuan {
    return _pengajuanList.where((p) => p.status == 'Menunggu').toList();
  }

  // Ambil pengajuan yang sudah disetujui
  List<PengajuanModel> get approvedPengajuan {
    return _pengajuanList.where((p) => p.status == 'Disetujui').toList();
  }

  // Ambil pengajuan cuti yang sudah disetujui dan sedang berlangsung hari ini
  List<PengajuanModel> get cutiBerlangsungHariIni {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    return _pengajuanList.where((p) {
      // Hanya untuk pengajuan cuti yang sudah disetujui
      if (p.status != 'Disetujui') return false;
      
      // Cek apakah tipe adalah cuti
      final isCuti = p.tipe.toLowerCase().contains('cuti') || 
                     p.tipe.toLowerCase().contains('izin');
      if (!isCuti) return false;
      
      // Cek apakah ada detail tanggal
      if (p.detail == null) return false;
      
      try {
        final tanggalMulaiStr = p.detail!['tanggalMulai'] as String?;
        final tanggalSelesaiStr = p.detail!['tanggalSelesai'] as String?;
        
        if (tanggalMulaiStr == null || tanggalSelesaiStr == null) return false;
        
        final tanggalMulai = DateTime.parse(tanggalMulaiStr);
        final tanggalSelesai = DateTime.parse(tanggalSelesaiStr);
        
        final mulaiDate = DateTime(tanggalMulai.year, tanggalMulai.month, tanggalMulai.day);
        final selesaiDate = DateTime(tanggalSelesai.year, tanggalSelesai.month, tanggalSelesai.day);
        
        // Cek apakah hari ini berada dalam rentang cuti
        return todayDate.isAfter(mulaiDate.subtract(const Duration(days: 1))) &&
               todayDate.isBefore(selesaiDate.add(const Duration(days: 1)));
      } catch (e) {
        debugPrint('Error parsing tanggal cuti: $e');
        return false;
      }
    }).toList();
  }

  Future<void> loadPengajuan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _pengajuanList = jsonList
            .map((json) => PengajuanModel.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading pengajuan: $e');
    }
  }

  Future<void> savePengajuan(PengajuanModel pengajuan) async {
    try {
      _pengajuanList.add(pengajuan);
      await _saveToStorage();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving pengajuan: $e');
    }
  }

  Future<void> updatePengajuanStatus(String id, String status) async {
    try {
      final index = _pengajuanList.indexWhere((p) => p.id == id);
      if (index != -1) {
        final pengajuan = _pengajuanList[index];
        _pengajuanList[index] = PengajuanModel(
          id: pengajuan.id,
          nama: pengajuan.nama,
          tipe: pengajuan.tipe,
          tanggal: pengajuan.tanggal,
          alasan: pengajuan.alasan,
          status: status,
          detail: pengajuan.detail,
        );
        // Simpan ke storage secara async (tidak blocking)
        _saveToStorage();
        // Notify listeners segera untuk realtime update
        notifyListeners();
        debugPrint('Pengajuan ${pengajuan.nama} status diupdate menjadi: $status');
      }
    } catch (e) {
      debugPrint('Error updating pengajuan: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _pengajuanList.map((p) => p.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving to storage: $e');
    }
  }

  Future<void> deletePengajuan(String id) async {
    try {
      _pengajuanList.removeWhere((p) => p.id == id);
      await _saveToStorage();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting pengajuan: $e');
    }
  }
}


