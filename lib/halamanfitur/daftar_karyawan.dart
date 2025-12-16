import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:skeletonizer/skeletonizer.dart';
// Import AttendanceService
import 'attendance_service.dart';
import 'package:aplikasi_tugasakhir_presensi/services/pengajuan_service.dart';
import 'dart:io';
import 'detail_karyawan_page.dart';

class Karyawan {
  final String nama;
  final String jabatan;
  final String status;
  final String waktu;
  final String lokasi;
  final String tag1;
  final String tag2;
  final String imageUrl;
  final DateTime? timestamp; // Tambahkan timestamp untuk sorting

  Karyawan({
    required this.nama,
    required this.jabatan,
    required this.status,
    required this.waktu,
    required this.lokasi,
    required this.tag1,
    required this.tag2,
    required this.imageUrl,
    this.timestamp,
  });

  // Factory constructor dari AttendanceRecord
  factory Karyawan.fromAttendanceRecord(AttendanceRecord record) {
    final lokasiText = record.locationType;
    final tag1 = record.isClockIn ? 'Regular Hours' : 'Overtime';
    final tag2 = record.locationType;
    final waktuText = '${record.fullTimeText} ${record.address}';
    return Karyawan(
      nama: record.employeeName,
      jabatan: record.position,
      status: record.statusText,
      waktu: waktuText,
      lokasi: lokasiText,
      tag1: tag1,
      tag2: tag2,
      imageUrl: record.photoPath ?? '',
      timestamp: record.timestamp,
    );
  }
}

class DaftarKaryawan extends StatefulWidget {
  @override
  _DaftarKaryawanState createState() => _DaftarKaryawanState();
}

class _DaftarKaryawanState extends State<DaftarKaryawan> with SingleTickerProviderStateMixin {
  bool _loading = true;
  String selectedSort = 'Clock In (Desc)';
  TabController? _tabController;
  final AttendanceService _attendanceService = AttendanceService();
  final PengajuanService _pengajuanService = PengajuanService();
  bool _isRefreshing = false; // Flag untuk mencegah infinite loop

  final List<String> sortingOptions = [
    'Clock In (Desc)',
    'Clock In (Asc)',
    'Nama (A-Z)',
    'Nama (Z-A)',
  ];

  // Data sumber daftar karyawan, akan diisi dari AttendanceService
  List<Karyawan> _daftarKaryawan = [];
  List<Karyawan> _karyawanLiburCache = []; // Cache untuk karyawan libur

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _attendanceService.addListener(_onDataChanged);
    _pengajuanService.addListener(_onDataChanged);
    _loadData();
  }

  @override
  void dispose() {
    _attendanceService.removeListener(_onDataChanged);
    _pengajuanService.removeListener(_onDataChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _loadData() async {
    // Load pengajuan terlebih dahulu
    try {
      await _pengajuanService.loadPengajuan();
    } catch (e) {
      debugPrint('Error loading pengajuan in _loadData: $e');
    }
    
    Future.delayed(const Duration(seconds: 2), () {
      _refreshData();
    });
  }

  // Handler untuk perubahan data - Realtime update tanpa delay
  void _onDataChanged() {
    if (_isRefreshing || !mounted) return; // Mencegah infinite loop
    
    // Update cache karyawan libur langsung dari memory
    // Data sudah di-update oleh PengajuanService sebelum notifyListeners()
    _updateKaryawanLiburCache();
    
    // Update UI langsung tanpa delay untuk realtime
    if (mounted) {
      setState(() {
        // Trigger rebuild untuk update UI dengan data terbaru
        _sortData(); // Re-sort data jika perlu
      });
    }
  }

  void _refreshData() async {
    if (!mounted || _isRefreshing) return;
    
    _isRefreshing = true;
    
    try {
      if (mounted) {
        setState(() {
          _loading = true;
        });
      }

      // Update cache karyawan libur dengan data terbaru dari memory
      // Tidak perlu load ulang karena PengajuanService sudah update di memory
      _updateKaryawanLiburCache();

      // Ambil data dari AttendanceService
      try {
        final attendanceRecords = _attendanceService.attendanceRecords;
        if (mounted) {
          _daftarKaryawan = attendanceRecords.map((record) => Karyawan.fromAttendanceRecord(record)).toList();
        }
      } catch (e) {
        debugPrint('Error loading attendance: $e');
        if (mounted) {
          _daftarKaryawan = [];
        }
      }
      
      // Update cache karyawan libur sekali lagi setelah semua data di-load
      _updateKaryawanLiburCache();
      
      // Update UI langsung tanpa delay untuk realtime
      if (mounted) {
        setState(() {
          _loading = false;
          _sortData();
        });
      }
      _isRefreshing = false;
    } catch (e) {
      debugPrint('Error in _refreshData: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      _isRefreshing = false;
    }
  }

  // Update cache karyawan libur
  void _updateKaryawanLiburCache() {
    try {
      // Ambil data cuti yang berlangsung hari ini dari service
      final cutiBerlangsung = _pengajuanService.cutiBerlangsungHariIni;
      
      debugPrint('Cuti berlangsung hari ini: ${cutiBerlangsung.length}');
      
      List<Karyawan> karyawanLiburList = [];
      
      for (final cuti in cutiBerlangsung) {
        try {
          DateTime? tanggalMulai;
          DateTime? tanggalSelesai;
          try {
            if (cuti.detail != null) {
              final tanggalMulaiStr = cuti.detail!['tanggalMulai'] as String?;
              final tanggalSelesaiStr = cuti.detail!['tanggalSelesai'] as String?;
              
              if (tanggalMulaiStr != null && tanggalMulaiStr.isNotEmpty) {
                tanggalMulai = DateTime.parse(tanggalMulaiStr);
              }
              if (tanggalSelesaiStr != null && tanggalSelesaiStr.isNotEmpty) {
                tanggalSelesai = DateTime.parse(tanggalSelesaiStr);
              }
            }
          } catch (e) {
            debugPrint('Error parsing tanggal cuti: $e');
          }
          
          String tanggalDisplay = cuti.tanggal.isNotEmpty ? cuti.tanggal : 'Tanggal tidak tersedia';
          if (tanggalMulai != null && tanggalSelesai != null) {
            tanggalDisplay = '${tanggalMulai.day}/${tanggalMulai.month}/${tanggalMulai.year} - ${tanggalSelesai.day}/${tanggalSelesai.month}/${tanggalSelesai.year}';
          }
          
          debugPrint('Menambahkan ${cuti.nama} ke daftar libur');
          karyawanLiburList.add(
            Karyawan(
              nama: cuti.nama.isNotEmpty ? cuti.nama : 'Nama tidak tersedia',
              jabatan: '',
              status: 'Libur',
              waktu: tanggalDisplay,
              lokasi: cuti.tipe.isNotEmpty ? cuti.tipe : 'Cuti',
              tag1: cuti.tipe.isNotEmpty ? cuti.tipe : 'Cuti',
              tag2: 'Cuti Disetujui',
              imageUrl: '',
              timestamp: tanggalMulai ?? DateTime.now(),
            ),
          );
        } catch (e) {
          debugPrint('Error processing cuti: $e');
          continue;
        }
      }
      
      debugPrint('Total karyawan libur: ${karyawanLiburList.length}');
      _karyawanLiburCache = karyawanLiburList;
    } catch (e) {
      debugPrint('Error updating karyawan libur cache: $e');
      _karyawanLiburCache = [];
    }
  }

  void _sortData() {
    switch (selectedSort) {
      case 'Clock In (Desc)':
        _daftarKaryawan.sort((a, b) {
          if (a.timestamp == null || b.timestamp == null) return 0;
          return b.timestamp!.compareTo(a.timestamp!);
        });
        break;
      case 'Clock In (Asc)':
        _daftarKaryawan.sort((a, b) {
          if (a.timestamp == null || b.timestamp == null) return 0;
          return a.timestamp!.compareTo(b.timestamp!);
        });
        break;
      case 'Nama (A-Z)':
        _daftarKaryawan.sort((a, b) => a.nama.compareTo(b.nama));
        break;
      case 'Nama (Z-A)':
        _daftarKaryawan.sort((a, b) => b.nama.compareTo(a.nama));
        break;
    }
  }

  // Filter karyawan yang sedang kerja (termasuk yang sudah clock out hari ini)
  List<Karyawan> get karyawanSedangKerja {
    // Tampilkan semua record hari ini (baik Clock In maupun Clock Out)
    // karena semua ini adalah karyawan yang sudah bekerja hari ini
    final today = DateTime.now();
    return _daftarKaryawan.where((karyawan) {
      if (karyawan.timestamp == null) return false;
      // Filter berdasarkan tanggal hari ini
      final recordDate = DateTime(
        karyawan.timestamp!.year,
        karyawan.timestamp!.month,
        karyawan.timestamp!.day,
      );
      final todayDate = DateTime(today.year, today.month, today.day);
      return recordDate.isAtSameMomentAs(todayDate);
    }).toList();
  }

  // Filter karyawan yang libur (menggunakan cache untuk menghindari crash)
  List<Karyawan> get karyawanLibur {
    // Gunakan cache untuk menghindari error saat build
    return _karyawanLiburCache;
  }

  Widget buildKaryawanCard(Karyawan karyawan) {
    Color statusColor;
    IconData statusIcon;
    
    if (karyawan.status == 'Clock In') {
      statusColor = Colors.green;
      statusIcon = Icons.login;
    } else if (karyawan.status == 'Clock Out') {
      statusColor = Colors.orange;
      statusIcon = Icons.logout;
    } else if (karyawan.status == 'Libur') {
      statusColor = Colors.blue;
      statusIcon = Icons.beach_access;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.info;
    }
    
    // Cari AttendanceRecord yang sesuai untuk mendapatkan informasi lengkap
    AttendanceRecord? attendanceRecord;
    if (karyawan.status != 'Libur') {
      try {
        final records = _attendanceService.attendanceRecords;
        attendanceRecord = records.firstWhere(
          (record) => 
            record.employeeName == karyawan.nama &&
            record.timestamp.year == karyawan.timestamp?.year &&
            record.timestamp.month == karyawan.timestamp?.month &&
            record.timestamp.day == karyawan.timestamp?.day &&
            record.timestamp.hour == karyawan.timestamp?.hour &&
            record.timestamp.minute == karyawan.timestamp?.minute,
          orElse: () => records.firstWhere(
            (record) => record.employeeName == karyawan.nama,
            orElse: () => records.first,
          ),
        );
      } catch (e) {
        debugPrint('Error finding attendance record: $e');
      }
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Navigate ke halaman detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailKaryawanPage(
                nama: karyawan.nama,
                jabatan: karyawan.jabatan,
                status: karyawan.status,
                waktu: karyawan.waktu,
                lokasi: karyawan.lokasi,
                imageUrl: karyawan.imageUrl,
                timestamp: karyawan.timestamp,
                alamat: attendanceRecord?.address,
                catatan: attendanceRecord?.note,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  image: karyawan.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: (karyawan.imageUrl.startsWith('http') || karyawan.imageUrl.startsWith('https'))
                              ? NetworkImage(karyawan.imageUrl)
                              : FileImage(File(karyawan.imageUrl)) as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: karyawan.imageUrl.isEmpty
                    ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                    : null,
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Status dan waktu
                  Row(
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          karyawan.status == 'Libur' 
                            ? '${karyawan.status} - ${karyawan.waktu}'
                            : '${karyawan.status} pada ${karyawan.waktu}',
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Nama
                  Text(
                    karyawan.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  
                  // Jabatan
                  if (karyawan.jabatan.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      karyawan.jabatan,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (karyawan.tag1.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTagColor(karyawan.tag1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            karyawan.tag1,
                            style: TextStyle(
                              fontSize: 11,
                              color: _getTagTextColor(karyawan.tag1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (karyawan.tag2.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTagColor(karyawan.tag2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            karyawan.tag2,
                            style: TextStyle(
                              fontSize: 11,
                              color: _getTagTextColor(karyawan.tag2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                ),
              ),
              
              // Action buttons
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone, size: 20, color: Colors.grey),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Menghubungi ${karyawan.nama}...')),
                      );
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.chat, size: 20, color: Colors.grey),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Membuka chat dengan ${karyawan.nama}...')),
                      );
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onPressed: () {
                      // Navigate ke halaman detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailKaryawanPage(
                            nama: karyawan.nama,
                            jabatan: karyawan.jabatan,
                            status: karyawan.status,
                            waktu: karyawan.waktu,
                            lokasi: karyawan.lokasi,
                            imageUrl: karyawan.imageUrl,
                            timestamp: karyawan.timestamp,
                            alamat: attendanceRecord?.address,
                            catatan: attendanceRecord?.note,
                          ),
                        ),
                      );
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'flexible':
      case 'wfh':
        return Colors.blue.shade50;
      case 'regular office':
      case 'wfo':
        return Colors.green.shade50;
      case 'field work':
      case 'mobile':
        return Colors.orange.shade50;
      case 'early bird':
        return Colors.purple.shade50;
      case 'regular hours':
        return Colors.teal.shade50;
      case 'overtime':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getTagTextColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'flexible':
      case 'wfh':
        return Colors.blue.shade700;
      case 'regular office':
      case 'wfo':
        return Colors.green.shade700;
      case 'field work':
      case 'mobile':
        return Colors.orange.shade700;
      case 'early bird':
        return Colors.purple.shade700;
      case 'regular hours':
        return Colors.teal.shade700;
      case 'overtime':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget buildHeader() {
    try {
      final workingCount = karyawanSedangKerja.length;
      final liburCount = karyawanLibur.length;
      final totalCount = workingCount + liburCount;
      
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gradient AppBar
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0092C1),
                Color(0xFF00AEB4),
                Color(0xFF00CBA7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Daftar Karyawan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _refreshData,
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {
                  // Show notifications
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),

        // TabBar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
         
            tabs: [
              Tab(text: 'Sedang Kerja ($workingCount)'),
              Tab(text: 'Libur ($liburCount)'),
            ],
          ),
        ),

        // Dropdown sorting dan lokasi
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    value: selectedSort,
                    items: sortingOptions
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                'Urutkan: $item',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSort = value!;
                        _sortData();
                      });
                    },
                    buttonStyleData: const ButtonStyleData(height: 40),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_drop_down),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      width: 260,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Cabang: Semua',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Total Karyawan ($workingCount/$totalCount)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
    } catch (e) {
      debugPrint('Error in buildHeader: $e');
      // Return fallback header jika ada error
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0092C1),
                  Color(0xFF00AEB4),
                  Color(0xFF00CBA7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Daftar Karyawan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          buildHeader(),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Sedang Kerja
                RefreshIndicator(
                  onRefresh: () async {
                    _refreshData();
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: Skeletonizer(
                    enabled: _loading,
                    child: karyawanSedangKerja.isEmpty && !_loading
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.work_off, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada karyawan yang sedang kerja',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _loading ? 3 : karyawanSedangKerja.length,
                            itemBuilder: (context, index) {
                              if (_loading) {
                                return buildKaryawanCard(
                                  Karyawan(
                                    nama: 'Loading...',
                                    jabatan: 'Loading...',
                                    status: 'Clock In',
                                    waktu: 'Loading...',
                                    lokasi: 'Loading...',
                                    tag1: 'Loading',
                                    tag2: 'Loading',
                                    imageUrl: '',
                                  ),
                                );
                              }
                              return buildKaryawanCard(karyawanSedangKerja[index]);
                            },
                          ),
                  ),
                ),
                
                // Tab Libur
                RefreshIndicator(
                  onRefresh: () async {
                    _refreshData();
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: Skeletonizer(
                    enabled: _loading,
                    child: karyawanLibur.isEmpty && !_loading
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada karyawan yang libur',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _loading ? 2 : karyawanLibur.length,
                            itemBuilder: (context, index) {
                              if (_loading) {
                                return buildKaryawanCard(
                                  Karyawan(
                                    nama: 'Loading...',
                                    jabatan: 'Loading...',
                                    status: 'Clock Out',
                                    waktu: 'Loading...',
                                    lokasi: 'Loading...',
                                    tag1: 'Loading',
                                    tag2: 'Loading',
                                    imageUrl: '',
                                  ),
                                );
                              }
                              return buildKaryawanCard(karyawanLibur[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}