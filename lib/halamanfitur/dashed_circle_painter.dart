// ignore_for_file: unused_import, unused_field, unused_local_variable

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aplikasi_tugasakhir_presensi/halamanfitur/ClockOutResultPage.dart';

class DashedCirclePainter extends CustomPainter {
  final Color color;

  DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 10.0;
    const dashSpace = 5.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const totalDash = 360;
    for (double i = 0; i < totalDash; i += dashWidth + dashSpace) {
      final startAngle = i * (math.pi / 180);
      final sweepAngle = dashWidth * (math.pi / 180);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// ClockInPage class dilanjutkan sesuai kode sebelumnya
// (tidak ada perubahan logika lain yang perlu dimodifikasi)
// Tambahkan import berikut jika dipisah ke file lain:
// import 'package:aplikasi_tugasakhir_presensi/halamanfitur/dashed_circle_painter.dart';
