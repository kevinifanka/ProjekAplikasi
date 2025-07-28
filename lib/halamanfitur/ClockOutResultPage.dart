// ignore_for_file: unused_import, unused_field

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class ClockOutResultPage extends StatefulWidget {
  final String capturedImagePath;
  final Position? userPosition;
  final String userAddress;

  const ClockOutResultPage({
    Key? key,
    required this.capturedImagePath,
    this.userPosition,
    required this.userAddress,
  }) : super(key: key);

  @override
  _ClockOutResultPageState createState() => _ClockOutResultPageState();
}

class _ClockOutResultPageState extends State<ClockOutResultPage> {
  GoogleMapController? _mapController;
  String _currentTime = '';
  String _currentDate = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    // Update waktu setiap detik untuk realtime
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) _updateDateTime();
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now) + ' WIB';
      _currentDate = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(now);
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
                  Row(
                    children: [
                      Expanded(
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
                          label: Text('Copy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
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

  Future<void> _submitClockOut() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulasi proses submit (ganti dengan API call yang sebenarnya)
      await Future.delayed(const Duration(seconds: 2));
      
      // Tampilkan dialog sukses
      if (mounted) {
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
                    'Clock Out Berhasil!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waktu: $_currentTime\n$_currentDate',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Back to previous screen
                    Navigator.of(context).pop(); // Back to main screen
                  },
                  child: Text('OK'),
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
            content: Text('Gagal melakukan clock out: ${e.toString()}'),
            backgroundColor: Colors.red,
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
          'Clock Out',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {
              // Show help dialog
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Section - Fixed Height
          Container(
            height: MediaQuery.of(context).size.height * 0.4, // 40% dari tinggi layar
            width: double.infinity,
            child: widget.userPosition != null
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
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Content Section - Scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Data kehadiran siap untuk dikirim!',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Info dengan Koordinat
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blue, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lokasi Saat Ini',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.userAddress,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getCoordinatesText(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        if (widget.userPosition != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Akurasi: ${widget.userPosition!.accuracy.toStringAsFixed(1)}m',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Photo and Time Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Container
                      Container(
                        width: 80,
                        height: 100,
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

                      // Time and Date Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentTime,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[600],
                              ),
                            ),
                            Text(
                              _currentDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Catatan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Copy Koordinat Button
                                GestureDetector(
                                  onTap: () async {
                                    if (widget.userPosition != null) {
                                      final coordinates = '${widget.userPosition!.latitude}, ${widget.userPosition!.longitude}';
                                      
                                      // Copy ke clipboard
                                      await Clipboard.setData(ClipboardData(text: coordinates));
                                      
                                      // Show snackbar
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(Icons.copy, color: Colors.white, size: 16),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text('Koordinat disalin: $coordinates'),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue[200]!),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.copy, size: 12, color: Colors.blue[700]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Copy Koordinat',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Detail Location Button
                      GestureDetector(
                        onTap: _showDetailedLocationDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Detail Lokasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Refresh Button
                      GestureDetector(
                        onTap: () {
                          // Refresh location
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, size: 16, color: Colors.blue[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Refresh',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Change Photo Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Center(
                      child: Text(
                        '(02:40) Ubah Foto',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: Container(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _isProcessing ? null : () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Clock Out Button
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _submitClockOut,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
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
                                    '(04:40) Clock Out',
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

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
}