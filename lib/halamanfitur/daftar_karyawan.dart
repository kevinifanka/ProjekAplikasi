import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Karyawan {
  final String nama;
  final String jabatan;
  final String status;
  final String waktu;
  final String lokasi;
  final String tag1;
  final String tag2;
  final String imageUrl;

  Karyawan({
    required this.nama,
    required this.jabatan,
    required this.status,
    required this.waktu,
    required this.lokasi,
    required this.tag1,
    required this.tag2,
    required this.imageUrl,
  });
}

class DaftarKaryawan extends StatefulWidget {
  @override
  _DaftarKaryawanState createState() => _DaftarKaryawanState();
}

class _DaftarKaryawanState extends State<DaftarKaryawan> with SingleTickerProviderStateMixin {
  bool _loading = true;
  String selectedSort = 'Clock In (Desc)';
  TabController? _tabController;

  final List<String> sortingOptions = [
    'Clock In (Desc)',
    'Clock In (Asc)',
    'Nama (A-Z)',
    'Nama (Z-A)',
  ];

  final List<Karyawan> daftarKaryawan = [
    Karyawan(
      nama: 'Alfian Agusnady',
      jabatan: 'BIS Head Engineer',
      status: 'Clock In',
      waktu: '17:03 PT. Media Antar Nusa',
      lokasi: 'WFH',
      tag1: 'Flexible',
      tag2: 'WFH',
      imageUrl: 'https://i.pravatar.cc/150?img=1',
    ),
    Karyawan(
      nama: 'Dodi Lesmana',
      jabatan: 'Surveyor',
      status: 'Clock Out',
      waktu: '17:00 PT. Media Antar Nusa',
      lokasi: 'WFO',
      tag1: 'Regular Office',
      tag2: 'WFO',
      imageUrl: 'https://i.pravatar.cc/150?img=2',
    ),
    Karyawan(
      nama: 'Ryan Al Farisi',
      jabatan: 'HRIS Product Engineer',
      status: 'Clock In',
      waktu: '12:27 Diluar',
      lokasi: 'WFH',
      tag1: 'Flexible',
      tag2: 'WFH',
      imageUrl: 'https://i.pravatar.cc/150?img=3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _loading = false;
      });
    });
  }

  Widget buildKaryawanCard(Karyawan karyawan) {
    Color statusColor = karyawan.status == 'Clock In' ? Colors.green : Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(karyawan.imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${karyawan.status} pada ${karyawan.waktu}',
                          style: TextStyle(fontSize: 12, color: statusColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    karyawan.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(karyawan.jabatan),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      Chip(label: Text(karyawan.tag1), backgroundColor: Colors.blue.shade50),
                      Chip(label: Text(karyawan.tag2), backgroundColor: Colors.purple.shade50),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: const [
                Icon(Icons.phone, size: 20, color: Colors.grey),
                SizedBox(height: 6),
                Icon(Icons.chat, size: 20, color: Colors.grey),
                SizedBox(height: 6),
                Icon(Icons.email, size: 20, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
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
            title: const Text('Daftar Karyawan'),
            actions: const [
              Icon(Icons.search, color: Colors.white),
              SizedBox(width: 10),
              Icon(Icons.help_outline, color: Colors.white),
              SizedBox(width: 10),
              Icon(Icons.notifications_none, color: Colors.white),
              SizedBox(width: 10),
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
            tabs: const [
              Tab(text: 'Sedang Kerja'),
              Tab(text: 'Libur'),
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    value: selectedSort,
                    items: sortingOptions
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                'Urutkan Berdasarkan: $item',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSort = value!;
                      });
                    },
                    buttonStyleData: const ButtonStyleData(height: 40),
                    iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down)),
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
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Karyawan (30/168)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            buildHeader(),
            const Divider(height: 0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Skeletonizer(
                    enabled: _loading,
                    child: ListView.builder(
                      itemCount: daftarKaryawan.length,
                      itemBuilder: (context, index) {
                        return buildKaryawanCard(daftarKaryawan[index]);
                      },
                    ),
                  ),
                  const Center(child: Text("Tidak ada data libur")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
