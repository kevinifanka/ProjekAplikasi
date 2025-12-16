import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aplikasi_tugasakhir_presensi/services/pengajuan_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PengajuanPerubahanShiftPage extends StatefulWidget {
  const PengajuanPerubahanShiftPage({Key? key}) : super(key: key);

  @override
  _PengajuanPerubahanShiftPageState createState() => _PengajuanPerubahanShiftPageState();
}

class _PengajuanPerubahanShiftPageState extends State<PengajuanPerubahanShiftPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _tanggalShift;
  String? _shiftLama;
  String? _shiftBaru;
  final TextEditingController _alasanController = TextEditingController();
  List<File> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _shiftOptions = ["Pagi", "Siang", "Malam"];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggalShift = picked);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _attachments.add(File(image.path)));
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_tanggalShift == null || _shiftLama == null || _shiftBaru == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Harap lengkapi semua field")),
        );
        return;
      }

      // Ambil nama user dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final nama = prefs.getString('name') ?? 'Pengguna';

      // Format tanggal
      final tanggalStr = DateFormat('dd/MM/yyyy').format(_tanggalShift!);
      final tanggalDetail = '$tanggalStr | Shift: $_shiftLama → $_shiftBaru';

      // Simpan ke PengajuanService
      final pengajuanService = PengajuanService();
      await pengajuanService.loadPengajuan();
      
      final pengajuan = PengajuanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        tipe: 'Perubahan Shift',
        tanggal: tanggalDetail,
        alasan: _alasanController.text.isEmpty ? 'Perubahan shift kerja' : _alasanController.text,
        status: 'Menunggu',
        detail: {
          'tanggal': _tanggalShift!.toIso8601String(),
          'shiftLama': _shiftLama,
          'shiftBaru': _shiftBaru,
        },
      );

      await pengajuanService.savePengajuan(pengajuan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengajuan perubahan shift berhasil diajukan!"),
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
      appBar: AppBar(title: Text("Pengajuan Perubahan Shift")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildDateField(),
            SizedBox(height: 16),
            _buildDropdownField("Shift Lama", _shiftLama, (val) => setState(() => _shiftLama = val)),
            SizedBox(height: 16),
            _buildDropdownField("Shift Baru", _shiftBaru, (val) => setState(() => _shiftBaru = val)),
            SizedBox(height: 16),
            TextFormField(
              controller: _alasanController,
              decoration: InputDecoration(labelText: "Alasan Perubahan Shift"),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? "Harus diisi" : null,
            ),
            SizedBox(height: 16),
            _buildAttachmentSection(),
            SizedBox(height: 24),
            ElevatedButton(onPressed: _submit, child: Text("Ajukan Perubahan Shift")),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() => GestureDetector(
        onTap: _selectDate,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Text(_tanggalShift != null
              ? "${_tanggalShift!.day}/${_tanggalShift!.month}/${_tanggalShift!.year}"
              : "Pilih Tanggal Shift"),
        ),
      );

  Widget _buildDropdownField(String label, String? value, Function(String?) onChanged) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text("Pilih $label"),
                isExpanded: true,
                items: _shiftOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      );

  Widget _buildAttachmentSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Lampiran (opsional)"),
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
  