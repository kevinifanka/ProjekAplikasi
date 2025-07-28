import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CutiHariPage extends StatefulWidget {
  @override
  _CutiHariPageState createState() => _CutiHariPageState();
}

class _CutiHariPageState extends State<CutiHariPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Simulasi loading selama 2 detik
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
          title: Text(
            'DAFTAR CUTI',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        ),
      body: Skeletonizer(
        enabled: _loading,
        child: ListView.builder(
          itemCount: 7,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text('Nama Karyawan $index'),
                subtitle: const Text('Jabatan / Departemen'),
                trailing: const Icon(Icons.person),
              ),
            );
          },
        ),
      ),
    );
  }
}
