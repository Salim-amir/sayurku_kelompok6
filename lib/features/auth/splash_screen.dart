import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data untuk 3 slide
  final List<Map<String, dynamic>> _splashData = [
    {
      "title": "SayurKu",
      "subtitle": "Segar Langsung ke Rumah",
      "bottomLabel": "KUALITAS KEBUN TERBAIK",
      "icon": Icons.eco_rounded,
    },
    {
      "title": "Pengiriman Kilat",
      "subtitle": "Sayur dipetik hari ini, sampai hari ini juga.",
      "bottomLabel": "CEPAT DAN AMAN",
      "icon": Icons.local_shipping_rounded,
    },
    {
      "title": "Transaksi Aman",
      "subtitle": "Berbagai metode pembayaran yang mudah.",
      "bottomLabel": "100% TERJAMIN",
      "icon": Icons.security_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage == _splashData.length - 1) {
      // Jika di slide terakhir, pindah ke Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // Geser ke slide berikutnya
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _onSkipPressed() {
    // Langsung lompat ke Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // --- BACKGROUND DEKORASI ---
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen.withOpacity(0.07),
              ),
            ),
          ),

          // --- KONTEN SLIDE ---
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _splashData.length,
            itemBuilder: (context, index) {
              return _buildSlideContent(_splashData[index]);
            },
          ),

          // --- NAVIGASI BAWAH ---
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Text(
                  _splashData[_currentPage]["bottomLabel"],
                  style: AppTextStyles.labelUppercase,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _splashData.length,
                    (index) => _buildDotIndicator(index == _currentPage),
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _onSkipPressed,
                      child: Text(
                        "Lewati",
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        _currentPage == _splashData.length - 1
                            ? "Mulai"
                            : "Selanjutnya",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildSlideContent(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(data["icon"], color: AppColors.primaryGreen, size: 52),
          ),
          const SizedBox(height: 32),
          Text(
            data["title"],
            style: AppTextStyles.appName,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            data["subtitle"],
            style: AppTextStyles.appTagline.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryGreen
            : AppColors.primaryGreen.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
