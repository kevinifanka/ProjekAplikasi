import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_tugasakhir_presensi/services/pengajuan_service.dart';
import 'package:aplikasi_tugasakhir_presensi/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PermintaanGajiPage extends StatefulWidget {
  const PermintaanGajiPage({super.key});

  @override
  _PermintaanGajiPageState createState() => _PermintaanGajiPageState();
}

class _PermintaanGajiPageState extends State<PermintaanGajiPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _periodeBulan;
  String? _metodePembayaran;
  final TextEditingController _jumlahGajiController = TextEditingController();
  final TextEditingController _alasanController = TextEditingController();
  final TextEditingController _nomorRekeningController = TextEditingController();
  final TextEditingController _namaRekeningController = TextEditingController();
  List<File> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _metodePembayaranOptions = [
    'Transfer Bank',
    'Tunai',
    'E-Wallet',
  ];

  final List<String> _bankOptions = [
    'BCA',
    'Mandiri',
    'BNI',
    'BRI',
    'CIMB Niaga',
    'Bank Lainnya',
  ];

  String? _selectedBank;

  @override
  void dispose() {
    _jumlahGajiController.dispose();
    _alasanController.dispose();
    _nomorRekeningController.dispose();
    _namaRekeningController.dispose();
    super.dispose();
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Pilih Periode Gaji',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _periodeBulan = picked;
      });
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

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    // Remove non-numeric characters
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '';
    
    // Format as currency without symbol (will be added in prefix)
    int number = int.parse(digitsOnly);
    return NumberFormat('#,###', 'id_ID').format(number);
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_periodeBulan == null || _metodePembayaran == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Harap lengkapi semua field yang wajib diisi")),
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
            folder: 'salary_requests',
            userId: userId,
          );
        } catch (e) {
          print('Error uploading attachments: $e');
          // Lanjutkan tanpa attachment jika upload gagal
        }
      }

      // Parse jumlah gaji (hilangkan format currency)
      final jumlahGajiStr = _jumlahGajiController.text.replaceAll(RegExp(r'[^\d]'), '');
      final jumlahGaji = jumlahGajiStr.isEmpty ? 0 : int.parse(jumlahGajiStr);

      // Simpan ke Firestore
      try {
        final firebaseService = FirebaseService();
        await firebaseService.saveSalaryRequest(
          userId: userId,
          employeeName: nama,
          periode: _periodeBulan!,
          jumlahGaji: jumlahGaji,
          metodePembayaran: _metodePembayaran!,
          bank: _selectedBank,
          nomorRekening: _nomorRekeningController.text.isEmpty ? null : _nomorRekeningController.text,
          namaRekening: _namaRekeningController.text.isEmpty ? null : _namaRekeningController.text,
          alasan: _alasanController.text.isEmpty ? 'Permintaan pembayaran gaji' : _alasanController.text,
          attachmentUrls: attachmentUrls,
        );
      } catch (e) {
        print('Error saving to Firestore: $e');
        // Tetap lanjutkan ke penyimpanan lokal
      }

      // Format periode dan detail untuk kompatibilitas lokal
      final periodeStr = DateFormat('MMMM yyyy', 'id_ID').format(_periodeBulan!);
      final jumlahGajiDisplay = _jumlahGajiController.text.isEmpty ? 'Tidak disebutkan' : 'Rp ${_jumlahGajiController.text}';
      final tanggalDetail = 'Periode: $periodeStr | $jumlahGajiDisplay | Metode: $_metodePembayaran';

      // Simpan ke PengajuanService lokal juga (untuk kompatibilitas)
      final pengajuanService = PengajuanService();
      await pengajuanService.loadPengajuan();
      
      final pengajuan = PengajuanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        tipe: 'Permintaan Gaji',
        tanggal: tanggalDetail,
        alasan: _alasanController.text.isEmpty ? 'Permintaan pembayaran gaji' : _alasanController.text,
        status: 'Menunggu',
        detail: {
          'periode': _periodeBulan!.toIso8601String(),
          'jumlahGaji': _jumlahGajiController.text,
          'metodePembayaran': _metodePembayaran,
          'nomorRekening': _nomorRekeningController.text,
          'namaRekening': _namaRekeningController.text,
        },
      );

      await pengajuanService.savePengajuan(pengajuan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan gaji Anda telah berhasil dikirim dan sedang menunggu persetujuan.'),
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
          'Permintaan Gaji',
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
                    _buildPeriodField(),
                    const SizedBox(height: 16),
                    _buildAmountField(),
                    const SizedBox(height: 16),
                    _buildPaymentMethodField(),
                    if (_metodePembayaran == 'Transfer Bank') ...[
                      const SizedBox(height: 16),
                      _buildBankField(),
                      const SizedBox(height: 16),
                      _buildAccountNumberField(),
                      const SizedBox(height: 16),
                      _buildAccountNameField(),
                    ],
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
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ajukan Permintaan Gaji',
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

  Widget _buildPeriodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Periode Gaji',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
            Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectMonth(context),
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
                  _periodeBulan != null
                      ? DateFormat('MMMM yyyy', 'id_ID').format(_periodeBulan!)
                      : 'Pilih periode gaji (Bulan/Tahun)',
                  style: TextStyle(
                    fontSize: 16,
                    color: _periodeBulan != null ? Colors.black87 : Colors.grey[500],
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

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Jumlah Gaji',
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
            controller: _jumlahGajiController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah gaji yang diminta',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixText: 'Rp ',
              prefixStyle: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Jumlah gaji harus diisi';
              }
              String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digitsOnly.isEmpty || int.parse(digitsOnly) <= 0) {
                return 'Jumlah gaji harus lebih dari 0';
              }
              return null;
            },
            onChanged: (value) {
              // Format currency as user types
              String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digitsOnly.isNotEmpty) {
                String formatted = _formatCurrency(digitsOnly);
                if (formatted != value.replaceAll(RegExp(r'[^\d]'), '')) {
                  final cursorPosition = _jumlahGajiController.selection.start;
                  _jumlahGajiController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: cursorPosition > formatted.length ? formatted.length : cursorPosition,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Metode Pembayaran',
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
              value: _metodePembayaran,
              hint: Text('Pilih metode pembayaran',
                  style: TextStyle(color: Colors.grey[500])),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
              items: _metodePembayaranOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _metodePembayaran = newValue;
                  if (newValue != 'Transfer Bank') {
                    _selectedBank = null;
                    _nomorRekeningController.clear();
                    _namaRekeningController.clear();
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Bank',
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
              value: _selectedBank,
              hint: Text('Pilih bank',
                  style: TextStyle(color: Colors.grey[500])),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
              items: _bankOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBank = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Nomor Rekening',
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
            controller: _nomorRekeningController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan nomor rekening',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nomor rekening harus diisi';
              }
              if (value.length < 10) {
                return 'Nomor rekening minimal 10 digit';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Nama Pemilik Rekening',
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
            controller: _namaRekeningController,
            decoration: InputDecoration(
              hintText: 'Masukkan nama pemilik rekening',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama pemilik rekening harus diisi';
              }
              return null;
            },
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
            Text('Alasan Permintaan',
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
              hintText: 'Masukkan alasan permintaan gaji...',
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
        const SizedBox(height: 4),
        Text(
          'Opsional - Upload bukti pendukung jika diperlukan',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
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
}

