import 'package:flutter/material.dart';
import 'package:aplikasi_tugasakhir_presensi/services/pengajuan_service.dart';

class ApprovalDashboard extends StatefulWidget {
  const ApprovalDashboard({super.key});

  @override
  State<ApprovalDashboard> createState() => _ApprovalDashboardState();
}

class _ApprovalDashboardState extends State<ApprovalDashboard> {
  final PengajuanService _pengajuanService = PengajuanService();

  @override
  void initState() {
    super.initState();
    _loadPengajuan();
    // Listen untuk perubahan data
    _pengajuanService.addListener(_onPengajuanChanged);
  }

  @override
  void dispose() {
    _pengajuanService.removeListener(_onPengajuanChanged);
    super.dispose();
  }

  void _onPengajuanChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadPengajuan() async {
    await _pengajuanService.loadPengajuan();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    await _pengajuanService.updatePengajuanStatus(id, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pengajuan $status."),
          backgroundColor: status == "Disetujui" ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingPengajuan = _pengajuanService.pendingPengajuan;

    return Scaffold(
      appBar: AppBar(
        title: const Text("HRD Admin - Approval Dashboard"),
        backgroundColor: Colors.blueAccent,
      ),
      body: pendingPengajuan.isEmpty
          ? const Center(
              child: Text(
                "Belum ada pengajuan yang menunggu persetujuan.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPengajuan,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingPengajuan.length,
                itemBuilder: (context, index) {
                  final pengajuan = pendingPengajuan[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pengajuan.nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTipeColor(pengajuan.tipe).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  pengajuan.tipe,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getTipeColor(pengajuan.tipe),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tanggal: ${pengajuan.tanggal}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Alasan: ${pengajuan.alasan}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Menunggu",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateStatus(pengajuan.id, "Disetujui");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text(
                                      "Setuju",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateStatus(pengajuan.id, "Ditolak");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text(
                                      "Tolak",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getTipeColor(String tipe) {
    switch (tipe) {
      case 'Cuti':
      case 'Cuti Tahunan':
      case 'Cuti Sakit':
      case 'Cuti Melahirkan':
      case 'Cuti Menikah':
      case 'Cuti Khusus':
      case 'Izin Tidak Masuk':
        return Colors.red;
      case 'Lembur':
        return Colors.orange;
      case 'Hadir Manual':
        return Colors.blue;
      case 'Perubahan Shift':
        return Colors.purple;
      case 'Permintaan Gaji':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
