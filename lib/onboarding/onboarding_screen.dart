import 'package:flutter/material.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/oneboarding_page1.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/oneboarding_page2.dart';
import 'package:aplikasi_tugasakhir_presensi/onboarding/oneboarding_page3.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    OnboardingPage1(),
    OnboardingPage2(),
    OnboardingPage3(),
  ];

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Langsung ke halaman register setelah onboarding selesai
      Navigator.pushReplacementNamed(context, '/register');
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentIndex > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF0961F5)),
                    onPressed: _previousPage,
                  ),
                ),
              ),

            // 📄 Konten Halaman
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: _pages,
              ),
            ),

            // 🔘 Indicator Halaman
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 15 : 7,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? const Color(0xFF0961F5) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
            ),

            // 🔽 Tombol Lanjut & Lewati
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0961F5),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentIndex < _pages.length - 1
                            ? "Lanjutkan"
                            : "Mulai Sekarang",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Langsung ke halaman register saat lewati
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text("Lewati", style: TextStyle(color: Color(0xFF0961F5))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
