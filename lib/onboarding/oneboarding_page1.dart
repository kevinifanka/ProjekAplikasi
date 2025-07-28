import 'package:flutter/material.dart';

class OnboardingPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          Spacer(),
          Image.asset(
              'images/face.png',
              width: 200,
              height: 200,
            ),
          Text(
            "Smart Clock In Presensi",
              style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "Aplikasi digital modern yang memudahkan Karyawan melakukan sistem clock in dan clock out secara efisien",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Spacer(flex: 1),
        ],
        
      ),
      
    );
    
    
  }
}
