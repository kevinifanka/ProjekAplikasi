import 'package:flutter/material.dart';

class OnboardingPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 70),
      child: Column(
        children: [
          Spacer(),
          Image.asset('images/Android Face.png', width: 200, height: 200),
          SizedBox(height: 24),
          Text(
            "Presensi Mudah dan Cepat",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: Color(0xFF0961F5),
              fontSize: 20),
            
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            "Dengan fitur Clock In dan Clock Out, pegawai dapat mencatat kehadiran secara real-time langsung dari aplikasi.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Spacer(flex: 2,),
        ],
      ),
    );
  }
}
