import 'package:aplikasi_tugasakhir_presensi/services/pengajuan_service.dart';
import 'package:aplikasi_tugasakhir_presensi/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PengajuanCutiPage extends StatefulWidget {
  const PengajuanCutiPage({super.key});

  @override
  _PengajuanCutiPageState createState() => _PengajuanCutiPageState();
}

class Pengajuan {
  final String nama;
  final String tipe;
  final String tanggal;
  final String alasan;
  final String status;

  Pengajuan({
    required this.nama,
    required this.tipe,
    required this.tanggal,
    required this.alasan,
    required this.status,
  });
}

class _PengajuanCutiPageState extends State<PengajuanCutiPage> {
  List<Pengajuan> daftarPengajuan = [
    Pengajuan(
        nama: "Kevin Ifanka",
        tipe: "Cuti Tahunan",
        tanggal: "12/12/2024 - 14/12/2024 (3 hari)",
        alasan: "Liburan keluarga",
        status: "Menunggu"),
    Pengajuan(
        nama: "Alice Johnson",
        tipe: "Cuti Sakit",
        tanggal: "01/11/2024 - 03/11/2024 (3 hari)",
        alasan: "Sakit flu berat",
        status: "Disetujui"),
    Pengajuan(
        nama: "Bob Smith",
        tipe: "Cuti Melahirkan",
        tanggal: "15/10/2024 - 30/10/2024 (16 hari)",
        alasan: "Melahirkan anak pertama",
        status: "Ditolak"),
  ];

  final _formKey = GlobalKey<FormState>();
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  String? _jenisCuti;
  int _jumlahHari = 0;
  final TextEditingController _alasanController = TextEditingController();
  List<File> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _jenisCutiOptions = [
    'Cuti Tahunan',
    'Cuti Sakit',
    'Cuti Melahirkan',
    'Cuti Menikah',
    'Cuti Khusus',
    'Izin Tidak Masuk'
  ];

  void _calculateDays() {
    if (_tanggalMulai != null && _tanggalSelesai != null) {
      setState(() {
        _jumlahHari = _tanggalSelesai!.difference(_tanggalMulai!).inDays + 1;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _tanggalMulai = picked;
        } else {
          _tanggalSelesai = picked;
        }
      });
      _calculateDays();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _attachments.add(File(image.path));
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_tanggalMulai == null || _tanggalSelesai == null || _jenisCuti == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Harap lengkapi semua field")),
        );
        return;
      }

      // Ambil data user dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final nama = prefs.getString('name') ?? 'Pengguna';
      final userId = prefs.getString('userId') ?? '';

      // Upload attachment ke Firebase Storage jika ada
      List<String>? attachmentUrls;
      if (_attachments.isNotEmpty) {
        try {
          final firebaseService = FirebaseService();
          final filePaths = _attachments.map((file) => file.path).toList();
          attachmentUrls = await firebaseService.uploadMultipleFiles(
            filePaths: filePaths,
            folder: 'leave_requests',
            userId: userId,
          );
        } catch (e) {
          print('Error uploading attachments: $e');
          // Lanjutkan tanpa attachment jika upload gagal
        }
      }

      // Simpan ke Firestore
      try {
        final firebaseService = FirebaseService();
        await firebaseService.saveLeaveRequest(
          userId: userId,
          employeeName: nama,
          jenisCuti: _jenisCuti!,
          tanggalMulai: _tanggalMulai!,
          tanggalSelesai: _tanggalSelesai!,
          jumlahHari: _jumlahHari,
          alasan: _alasanController.text,
          attachmentUrls: attachmentUrls,
        );
      } catch (e) {
        print('Error saving to Firestore: $e');
        // Tetap lanjutkan ke penyimpanan lokal
      }

      // Format tanggal untuk kompatibilitas lokal
      final tanggalStr = "${_tanggalMulai!.day}/${_tanggalMulai!.month}/${_tanggalMulai!.year} - ${_tanggalSelesai!.day}/${_tanggalSelesai!.month}/${_tanggalSelesai!.year} ($_jumlahHari hari)";

      // Simpan ke PengajuanService lokal juga (untuk kompatibilitas)
      final pengajuanService = PengajuanService();
      await pengajuanService.loadPengajuan();
      
      final pengajuan = PengajuanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        tipe: _jenisCuti!,
        tanggal: tanggalStr,
        alasan: _alasanController.text,
        status: 'Menunggu',
        detail: {
          'tanggalMulai': _tanggalMulai!.toIso8601String(),
          'tanggalSelesai': _tanggalSelesai!.toIso8601String(),
          'jumlahHari': _jumlahHari,
        },
      );

      await pengajuanService.savePengajuan(pengajuan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengajuan cuti berhasil diajukan"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pengajuan Cuti',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateField(
                      label: 'Tanggal Mulai',
                      date: _tanggalMulai,
                      onTap: () => _selectDate(context, true),
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: 'Tanggal Selesai',
                      date: _tanggalSelesai,
                      onTap: () => _selectDate(context, false),
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(),
                    const SizedBox(height: 16),
                    _buildQuantityField(),
                    const SizedBox(height: 16),
                    _buildReasonField(),
                    const SizedBox(height: 24),
                    _buildAttachmentSection(),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ajukan Cuti',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Pilih tanggal',
                  style: TextStyle(
                    fontSize: 16,
                    color: date != null ? Colors.black87 : Colors.grey[500],
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Jenis Cuti',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
            Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _jenisCuti,
              hint: Text('Pilih jenis cuti',
                  style: TextStyle(color: Colors.grey[500])),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
              items: _jenisCutiOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _jenisCuti = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Jumlah Hari',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
            Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            '$_jumlahHari hari',
            style: TextStyle(
              fontSize: 16,
              color: _jumlahHari > 0 ? Colors.black87 : Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Alasan',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
            Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: _alasanController,
            maxLines: 4,
            maxLength: 250,
            decoration: InputDecoration(
              hintText: 'Masukkan alasan pengajuan cuti...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(color: Colors.grey[400]),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Alasan harus diisi';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lampiran',
            style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Icon(Icons.add, size: 32, color: Colors.grey[400]),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hanya mendukung file JPEG dan PNG\ndengan ukuran maksimal 1MB',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._attachments.asMap().entries.map((entry) {
            int index = entry.key;
            File file = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file.path.split('/').last,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red[400]),
                    onPressed: () => _removeAttachment(index),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }
}
