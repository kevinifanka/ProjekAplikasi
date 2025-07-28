import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Simulasi loading selama 5 detik
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.green,
      ),
      body: Skeletonizer(
        enabled: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Foto Profil
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=4'),
              ),

              const SizedBox(height: 16),

              // Nama
              const Text(
                'Kevin Ifanka',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Info lainnya
              const Text(
                'Mahasiswa Teknik Informatika',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                'Universitas Teknologi Indonesia',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // Tambahan Info atau Aksi
              ListTile(
                leading: Icon(Icons.email, color: Colors.green),
                title: Text('kevin.ifanka@example.com'),
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.green),
                title: Text('+62 812-3456-7890'),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.green),
                title: Text('Medan, Indonesia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
