import 'package:flutter/material.dart';

class OnboardingPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/face.png', width: 200, height: 200),
            SizedBox(height: 24),
            Text(
              "Presensi Akurat dengan Lokasi",
              style: 
              TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0961F5),
                 fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              "Sistem akan merekam lokasi saat presensi\nuntuk memastikan kehadiran karyawan\nsecara akurat",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
