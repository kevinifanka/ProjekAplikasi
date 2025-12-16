import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aplikasi_tugasakhir_presensi/services/pengajuan_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PengajuanLemburPage extends StatefulWidget {
  const PengajuanLemburPage({Key? key}) : super(key: key);

  @override
  _PengajuanLemburPageState createState() => _PengajuanLemburPageState();
}

class _PengajuanLemburPageState extends State<PengajuanLemburPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _tanggalLembur;
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;
  int _durasiJam = 0;
  final TextEditingController _alasanController = TextEditingController();
  List<File> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  void _hitungDurasi() {
    if (_jamMulai != null && _jamSelesai != null) {
      final startMinutes = _jamMulai!.hour * 60 + _jamMulai!.minute;
      final endMinutes = _jamSelesai!.hour * 60 + _jamSelesai!.minute;
      if (endMinutes > startMinutes) {
        setState(() {
          _durasiJam = ((endMinutes - startMinutes) / 60).round();
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggalLembur = picked);
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStart) {
          _jamMulai = picked;
        } else {
          _jamSelesai = picked;
        }
      });
      _hitungDurasi();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _attachments.add(File(image.path)));
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_tanggalLembur == null || _jamMulai == null || _jamSelesai == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Harap lengkapi semua field")),
        );
        return;
      }

      // Ambil nama user dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final nama = prefs.getString('name') ?? 'Pengguna';

      // Format tanggal dan waktu
      final tanggalStr = DateFormat('dd/MM/yyyy').format(_tanggalLembur!);
      final jamMulaiStr = '${_jamMulai!.hour.toString().padLeft(2, '0')}:${_jamMulai!.minute.toString().padLeft(2, '0')}';
      final jamSelesaiStr = '${_jamSelesai!.hour.toString().padLeft(2, '0')}:${_jamSelesai!.minute.toString().padLeft(2, '0')}';
      final tanggalWaktu = '$tanggalStr | $jamMulaiStr - $jamSelesaiStr ($_durasiJam jam)';

      // Simpan ke PengajuanService
      final pengajuanService = PengajuanService();
      await pengajuanService.loadPengajuan();
      
      final pengajuan = PengajuanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        tipe: 'Lembur',
        tanggal: tanggalWaktu,
        alasan: _alasanController.text.isEmpty ? 'Pengajuan lembur' : _alasanController.text,
        status: 'Menunggu',
        detail: {
          'tanggal': _tanggalLembur!.toIso8601String(),
          'jamMulai': '${_jamMulai!.hour}:${_jamMulai!.minute}',
          'jamSelesai': '${_jamSelesai!.hour}:${_jamSelesai!.minute}',
          'durasiJam': _durasiJam,
        },
      );

      await pengajuanService.savePengajuan(pengajuan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan lembur berhasil dikirim!'),
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
      appBar: AppBar(title: Text("Pengajuan Lembur")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildDateField(),
            SizedBox(height: 16),
            _buildTimeField("Jam Mulai", _jamMulai, () => _selectTime(context, true)),
            SizedBox(height: 16),
            _buildTimeField("Jam Selesai", _jamSelesai, () => _selectTime(context, false)),
            SizedBox(height: 16),
            Text("Durasi: $_durasiJam jam"),
            SizedBox(height: 16),
            _buildReasonField(),
            SizedBox(height: 16),
            _buildAttachmentSection(),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitRequest,
              child: Text("Ajukan Lembur"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() => GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Text(_tanggalLembur != null
              ? "${_tanggalLembur!.day}/${_tanggalLembur!.month}/${_tanggalLembur!.year}"
              : "Pilih Tanggal Lembur"),
        ),
      );

  Widget _buildTimeField(String label, TimeOfDay? time, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Text(time != null ? time.format(context) : label),
        ),
      );

  Widget _buildReasonField() => TextFormField(
        controller: _alasanController,
        decoration: InputDecoration(labelText: "Alasan Lembur"),
        validator: (v) => v!.isEmpty ? "Harus diisi" : null,
      );

  Widget _buildAttachmentSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Lampiran"),
          SizedBox(height: 8),
          ElevatedButton(onPressed: _pickImage, child: Text("Tambah File")),
          ..._attachments
              .map((f) => ListTile(
                    title: Text(f.path.split("/").last),
                    trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => setState(() => _attachments.remove(f))),
                  ))
              .toList()
        ],
      );
}
