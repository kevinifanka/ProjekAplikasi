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
      // ✅ Gunakan pushNamed agar bisa kembali dari halaman berikutnya
      Navigator.pushNamed(context, '/welcome');
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
                    icon: Icon(Icons.arrow_back),
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
                      color: _currentIndex == index ? Colors.amber : Colors.black,
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
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentIndex < _pages.length - 1
                            ? "Lanjutkan"
                            : "Mulai Sekarang",
                        style: TextStyle(color: Colors.yellowAccent),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // ✅ Gunakan pushNamed agar bisa kembali dari halaman Welcome
                      Navigator.pushNamed(context, '/welcome');
                    },
                    child: Text("Lewati", style: TextStyle(color: Colors.black)),
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
