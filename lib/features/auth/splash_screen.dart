import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../widgets/custom_button.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _splashData = [
    {
      "title": AppConstants.appName,
      "subtitle": AppConstants.appTagline,
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _onSkipPressed() {
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
                color: AppColors.accentGreen.withValues(alpha: 0.08),
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
                color: AppColors.accentGreen.withValues(alpha: 0.07),
              ),
            ),
          ),

          // --- KONTEN SLIDE ---
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _splashData.length,
            itemBuilder: (context, index) {
              return _buildSlideContent(_splashData[index]);
            },
          ),

          // --- NAVIGASI BAWAH ---
          Positioned(
            bottom: 40,
            left: AppConstants.paddingLG,
            right: AppConstants.paddingLG,
            child: Column(
              children: [
                Text(
                  _splashData[_currentPage]["bottomLabel"],
                  style: AppTextStyles.labelUppercase,
                ),
                const SizedBox(height: AppConstants.paddingMD),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _splashData.length,
                    (index) => _buildDotIndicator(index == _currentPage),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXL),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ganti dengan AppTextButton
                    AppTextButton(
                      label: "Lewati",
                      onPressed: _onSkipPressed,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    
                    // Ganti dengan AppPrimaryButton (dengan width custom)
                    AppPrimaryButton(
                      width: 140, // Atur lebar khusus biar gak kepanjangan
                      label: _currentPage == _splashData.length - 1 ? "Mulai" : "Selanjutnya",
                      onPressed: _onNextPressed,
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(data["icon"], color: AppColors.primaryGreen, size: 52),
          ),
          const SizedBox(height: AppConstants.paddingXL),
          Text(data["title"], style: AppTextStyles.appName, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.paddingSM),
          Text(data["subtitle"], style: AppTextStyles.appTagline.copyWith(fontSize: 16), textAlign: TextAlign.center),
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
        color: isActive ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
      ),
    );
  }
}