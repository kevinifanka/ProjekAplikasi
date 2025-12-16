import 'package:flutter/material.dart';
import 'package:aplikasi_tugasakhir_presensi/services/pengajuan_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KehadiranManualPage extends StatefulWidget {
  const KehadiranManualPage({super.key});

  @override
  State<KehadiranManualPage> createState() => _KehadiranManualPageState();
}

class _KehadiranManualPageState extends State<KehadiranManualPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _tanggal;
  TimeOfDay? _jamMasuk;
  TimeOfDay? _jamPulang;
  final TextEditingController _alasanController = TextEditingController();

  Future<void> _pickTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
      });
    }
  }

  Future<void> _pickJamMasuk() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _jamMasuk = picked;
      });
    }
  }

  Future<void> _pickJamPulang() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _jamPulang = picked;
      });
    }
  }

  Future<void> _ajukanKehadiranManual() async {
    if (_formKey.currentState!.validate()) {
      if (_tanggal == null || _jamMasuk == null || _jamPulang == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Harap lengkapi semua field")),
        );
        return;
      }

      // Ambil nama user dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final nama = prefs.getString('name') ?? 'Pengguna';

      // Format tanggal dan waktu
      final tanggalStr = DateFormat('dd/MM/yyyy').format(_tanggal!);
      final jamMasukStr = '${_jamMasuk!.hour.toString().padLeft(2, '0')}:${_jamMasuk!.minute.toString().padLeft(2, '0')}';
      final jamPulangStr = '${_jamPulang!.hour.toString().padLeft(2, '0')}:${_jamPulang!.minute.toString().padLeft(2, '0')}';
      final tanggalWaktu = '$tanggalStr | $jamMasukStr - $jamPulangStr';

      // Simpan ke PengajuanService
      final pengajuanService = PengajuanService();
      await pengajuanService.loadPengajuan();
      
      final pengajuan = PengajuanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        tipe: 'Hadir Manual',
        tanggal: tanggalWaktu,
        alasan: _alasanController.text,
        status: 'Menunggu',
        detail: {
          'tanggal': _tanggal!.toIso8601String(),
          'jamMasuk': '${_jamMasuk!.hour}:${_jamMasuk!.minute}',
          'jamPulang': '${_jamPulang!.hour}:${_jamPulang!.minute}',
        },
      );

      await pengajuanService.savePengajuan(pengajuan);

      // Reset form
      setState(() {
        _tanggal = null;
        _jamMasuk = null;
        _jamPulang = null;
        _alasanController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengajuan kehadiran manual berhasil diajukan"),
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
      appBar: AppBar(
        title: const Text("Kehadiran Manual"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tanggal
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text(
                  _tanggal == null
                      ? "Pilih Tanggal"
                      : "${_tanggal!.day}/${_tanggal!.month}/${_tanggal!.year}",
                ),
                onTap: _pickTanggal,
              ),
              const Divider(),

              // Jam Masuk
              ListTile(
                leading: const Icon(Icons.login, color: Colors.green),
                title: Text(
                  _jamMasuk == null
                      ? "Pilih Jam Masuk"
                      : _jamMasuk!.format(context),
                ),
                onTap: _pickJamMasuk,
              ),
              const Divider(),

              // Jam Pulang
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  _jamPulang == null
                      ? "Pilih Jam Pulang"
                      : _jamPulang!.format(context),
                ),
                onTap: _pickJamPulang,
              ),
              const Divider(),

              // Alasan
              TextFormField(
                controller: _alasanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Alasan (contoh: lupa clock in)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Harap isi alasan" : null,
              ),
              const SizedBox(height: 20),

              // Tombol
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _ajukanKehadiranManual,
                  icon: const Icon(Icons.send),
                  label: const Text("Ajukan Kehadiran Manual"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
