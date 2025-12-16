import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class DetailKaryawanPage extends StatelessWidget {
  final String nama;
  final String jabatan;
  final String status;
  final String waktu;
  final String lokasi;
  final String imageUrl;
  final DateTime? timestamp;
  final String? alamat;
  final String? catatan;

  const DetailKaryawanPage({
    Key? key,
    required this.nama,
    required this.jabatan,
    required this.status,
    required this.waktu,
    required this.lokasi,
    required this.imageUrl,
    this.timestamp,
    this.alamat,
    this.catatan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format tanggal dan waktu
    String tanggalText = '';
    String waktuText = '';
    if (timestamp != null) {
      tanggalText = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(timestamp!);
      waktuText = DateFormat('HH:mm:ss WIB').format(timestamp!);
    }

    // Warna status
    Color statusColor;
    IconData statusIcon;
    Color statusBgColor;
    
    if (status == 'Clock In') {
      statusColor = Colors.green;
      statusIcon = Icons.login;
      statusBgColor = Colors.green.shade50;
    } else if (status == 'Clock Out') {
      statusColor = Colors.orange;
      statusIcon = Icons.logout;
      statusBgColor = Colors.orange.shade50;
    } else if (status == 'Libur') {
      statusColor = Colors.blue;
      statusIcon = Icons.beach_access;
      statusBgColor = Colors.blue.shade50;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.info;
      statusBgColor = Colors.grey.shade50;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Karyawan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone, color: Colors.grey),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Menghubungi $nama...')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.chat, color: Colors.grey),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Membuka chat dengan $nama...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan foto dan nama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Foto profil
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      border: Border.all(
                        color: statusColor,
                        width: 4,
                      ),
                      image: imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: (imageUrl.startsWith('http') || imageUrl.startsWith('https'))
                                  ? NetworkImage(imageUrl)
                                  : FileImage(File(imageUrl)) as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl.isEmpty
                        ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Nama
                  Text(
                    nama,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Jabatan
                  if (jabatan.isNotEmpty)
                    Text(
                      jabatan,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Status Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        if (timestamp != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            waktuText,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            tanggalText,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Informasi Detail
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lokasi
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: 'Lokasi',
                    value: lokasi,
                    iconColor: Colors.blue,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Alamat
                  if (alamat != null && alamat!.isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.place,
                      label: 'Alamat',
                      value: alamat!,
                      iconColor: Colors.green,
                    ),
                  
                  if (alamat != null && alamat!.isNotEmpty)
                    const SizedBox(height: 16),
                  
                  // Catatan
                  if (catatan != null && catatan!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catatan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                catatan!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Menghubungi $nama...')),
                        );
                      },
                      icon: Icon(Icons.phone),
                      label: Text('Hubungi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Membuka chat dengan $nama...')),
                        );
                      },
                      icon: Icon(Icons.chat),
                      label: Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

