// ClockOutResultPage.dart - Modified Layout Version
// ignore_for_file: unused_import, unused_field

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import AttendanceService yang sudah dibuat
import 'attendance_service.dart';
import 'package:aplikasi_tugasakhir_presensi/services/firebase_service.dart';

class ClockOutResultPage extends StatefulWidget {
  final String capturedImagePath;
  final Position? userPosition;
  final String userAddress;
  final bool isClockIn; // Parameter untuk membedakan clock in/out
  final bool isSmileAccepted;

  const ClockOutResultPage({
    Key? key,
    required this.capturedImagePath,
    this.userPosition,
    required this.userAddress,
    this.isClockIn = false, // Default false untuk clock out
    this.isSmileAccepted = true,
  }) : super(key: key);

  @override
  _ClockOutResultPageState createState() => _ClockOutResultPageState();
}

class _ClockOutResultPageState extends State<ClockOutResultPage> {
  GoogleMapController? _mapController;
  String _currentTime = '';
  String _currentDate = '';
  bool _isProcessing = false;
  final TextEditingController _notesController = TextEditingController();
  final AttendanceService _attendanceService = AttendanceService();
  Timer? _countdownTimer;
  int _countdownSeconds = 180; // 3 menit = 180 detik

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    // Update waktu setiap detik untuk realtime
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) _updateDateTime();
    });
    // Start countdown timer
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatCountdown(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm').format(now) + ' WIB';
      _currentDate = DateFormat('EEE, dd MMM yyyy', 'id_ID').format(now);
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    
    if (widget.userPosition != null) {
      // Animasi ke lokasi user
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(widget.userPosition!.latitude, widget.userPosition!.longitude),
          16.0,
        ),
      );
    }
  }

  // Method untuk mendapatkan koordinat dalam format string
  String _getCoordinatesText() {
    if (widget.userPosition != null) {
      final lat = widget.userPosition!.latitude.toStringAsFixed(6);
      final lng = widget.userPosition!.longitude.toStringAsFixed(6);
      return 'Lat: $lat, Lng: $lng';
    }
    return 'Koordinat tidak tersedia';
  }

  // Method untuk mendapatkan koordinat yang lebih detail
  Future<String> _getDetailedLocationInfo() async {
    if (widget.userPosition == null) {
      return 'Lokasi tidak tersedia';
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.userPosition!.latitude,
        widget.userPosition!.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '''
${place.street ?? ''} ${place.subLocality ?? ''}
${place.locality ?? ''}, ${place.subAdministrativeArea ?? ''}
${place.administrativeArea ?? ''} ${place.postalCode ?? ''}
${place.country ?? ''}

Koordinat: ${widget.userPosition!.latitude.toStringAsFixed(6)}, ${widget.userPosition!.longitude.toStringAsFixed(6)}
Akurasi: ${widget.userPosition!.accuracy.toStringAsFixed(1)}m
''';
      }
    } catch (e) {
      print('Error getting placemark: $e');
    }
    
    return '''
${widget.userAddress}

Koordinat: ${widget.userPosition!.latitude.toStringAsFixed(6)}, ${widget.userPosition!.longitude.toStringAsFixed(6)}
Akurasi: ${widget.userPosition!.accuracy.toStringAsFixed(1)}m
''';
  }

  // Method untuk show dialog dengan info detail
  void _showDetailedLocationDialog() async {
    String locationInfo = await _getDetailedLocationInfo();
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Detail Lokasi'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    locationInfo,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (widget.userPosition != null) {
                          final coordinates = '${widget.userPosition!.latitude}, ${widget.userPosition!.longitude}';
                          await Clipboard.setData(ClipboardData(text: coordinates));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Koordinat disalin!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.copy, size: 16),
                      label: Text('Copy Koordinat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _submitAttendance() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Ambil data user dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('name') ?? 'Pengguna';
      final userId = prefs.getString('userId') ?? '';
      
      // Ambil departemen dari SharedPreferences atau Firestore
      String userPosition = prefs.getString('departemen') ?? 'Karyawan';
      
      // Jika belum ada di SharedPreferences, ambil dari Firestore
      if (userPosition == 'Karyawan' && userId.isNotEmpty) {
        try {
          final firebaseService = FirebaseService();
          final userData = await firebaseService.getUserData(userId);
          if (userData != null) {
            userPosition = userData['departemen'] ?? userData['position'] ?? 'Karyawan';
            // Simpan ke SharedPreferences untuk penggunaan selanjutnya
            await prefs.setString('departemen', userPosition);
          }
        } catch (e) {
          print('Error getting user data: $e');
        }
      }
      
      // Upload foto ke Firebase Storage jika ada
      String? photoUrl;
      if (widget.capturedImagePath.isNotEmpty && !kIsWeb) {
        try {
          final firebaseService = FirebaseService();
          photoUrl = await firebaseService.uploadPhoto(
            filePath: widget.capturedImagePath,
            folder: 'attendance',
            userId: userId,
          );
        } catch (e) {
          print('Error uploading photo: $e');
          // Lanjutkan tanpa foto jika upload gagal
        }
      }
      
      // Simpan data kehadiran ke Firestore
      final firebaseService = FirebaseService();
      await firebaseService.saveAttendance(
        userId: userId,
        employeeName: userName,
        position: userPosition,
        isClockIn: widget.isClockIn,
        address: widget.userAddress,
        photoUrl: photoUrl,
        note: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        locationType: 'WFO',
      );
      
      // Simpan data kehadiran ke service lokal juga (untuk kompatibilitas)
      final now = DateTime.now();
      _attendanceService.addRecord(
        AttendanceRecord(
          employeeName: userName,
          position: userPosition,
          isClockIn: widget.isClockIn,
          timestamp: now,
          address: widget.userAddress,
          photoPath: widget.capturedImagePath,
          note: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          locationType: 'WFO',
        ),
      );
      
      // Simpan status clock in/out ke SharedPreferences
      if (widget.isClockIn) {
        await prefs.setBool('isClockedIn', true);
        await prefs.setString('clockInTime', now.toIso8601String());
      } else {
        await prefs.setBool('isClockedIn', false);
        await prefs.remove('clockInTime');
      }
      
      final success = true;

      if (success && mounted) {
        // Tampilkan dialog sukses
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isClockIn ? 'Clock In Berhasil!' : 'Clock Out Berhasil!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waktu: $_currentTime\n$_currentDate\n\nData kehadiran telah disimpan ke daftar karyawan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Back to previous screen
                      Navigator.of(context).pop(); // Back to main screen
                    },
                    child: Text('OK'),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan ${widget.isClockIn ? 'clock in' : 'clock out'}: ${e.toString()}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildPhotoWidget() {
    if (kIsWeb) {
      // Untuk web, tampilkan placeholder atau gunakan network image
      return Container(
        color: Colors.grey[300],
        child: Icon(
          Icons.person,
          size: 40,
          color: Colors.grey[600],
        ),
      );
    } else {
      // Untuk mobile/desktop
      final file = File(widget.capturedImagePath);
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.grey[600],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isClockIn ? 'Clock In' : 'Clock Out',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Map Section - tinggi tetap sekitar 250-280px
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Stack(
              children: [
                // Google Map
                widget.userPosition != null
                    ? GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            widget.userPosition!.latitude,
                            widget.userPosition!.longitude,
                          ),
                          zoom: 16.0,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('user_location'),
                            position: LatLng(
                              widget.userPosition!.latitude,
                              widget.userPosition!.longitude,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                          ),
                        },
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        mapType: MapType.normal,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_off, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                'Lokasi tidak tersedia',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                
                // Location Info Overlay - positioned at bottom left of map
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.userAddress,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Bantuan jika lokasi tidak berubah',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Refresh Button - positioned at bottom right of map
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    elevation: 2,
                    child: InkWell(
                      onTap: () async {
                        // Refresh location
                        try {
                          final position = await Geolocator.getCurrentPosition(
                            timeLimit: const Duration(seconds: 10),
                          );
                          final placemarks = await placemarkFromCoordinates(
                            position.latitude,
                            position.longitude,
                          );
                          
                          if (placemarks.isNotEmpty && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lokasi diperbarui'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal memperbarui lokasi: $e'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 18, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              'Refresh',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),



          // Status Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: widget.isSmileAccepted ? Colors.blue[50] : Colors.red[50],
            child: Row(
              children: [
                Icon(
                  widget.isSmileAccepted ? Icons.info_outline : Icons.warning_amber,
                  color: widget.isSmileAccepted ? Colors.blue : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isSmileAccepted
                        ? 'Data kehadiran siap untuk dikirim!'
                        : 'Wajah Anda tidak tersenyum, mohon tersenyum lebar lalu ambil presensi kembali.',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.isSmileAccepted ? Colors.blue[800] : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section with Photo and Info
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Photo and Time Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Container
                      Container(
                        width: 100,
                        height: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildPhotoWidget(),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Time and Notes Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time
                            Text(
                              _currentTime,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            
                            // Date
                            Text(
                              _currentDate,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Catatan Label
                            Text(
                              'Catatan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Notes Input
                            TextFormField(
                              controller: _notesController,
                              decoration: InputDecoration(
                                hintText: 'Tambahkan catatan...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400],
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                isDense: true,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Change Photo Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: widget.isSmileAccepted ? Colors.green : Colors.red,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: widget.isSmileAccepted ? Colors.green : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isSmileAccepted ? 'Ambil Foto Ulang' : 'Ambil Foto Ulang & Tersenyum',
                            style: TextStyle(
                              color: widget.isSmileAccepted ? Colors.green : Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _isProcessing ? null : () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Clock In/Out Button
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isProcessing || !widget.isSmileAccepted ? null : _submitAttendance,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.isSmileAccepted ? Colors.green : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isProcessing
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    widget.isClockIn ? 'Clock In' : 'Clock Out',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (!widget.isSmileAccepted) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Clock in/out akan aktif setelah Anda tersenyum dan mengambil foto ulang.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // Extra bottom padding
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}