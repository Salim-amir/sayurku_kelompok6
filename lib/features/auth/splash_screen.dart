import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart'; 
import '../customer/shop/home_screen.dart'; 
import '../admin/dashboard/dashboard_admin_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // ── State untuk ngecek sesi login ──
  bool _isCheckingSession = true; 

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
  void initState() {
    super.initState();
    _checkUserSession(); // 👈 Panggil fungsi cek otomatis saat layar dimuat
  }

  // ── Logika Auto-Login (Bypass) ──
  Future<void> _checkUserSession() async {
    final authService = AuthService();
    final user = authService.currentUser;

    if (user != null) {
      try {
        // Cek role user di Firestore
        final doc = await FirebaseFirestore.instance
            .collection(AppConstants.colUsers)
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (doc.exists) {
          final role = doc.data()?['role'] ?? AppConstants.roleCustomer;
          
          // Lempar ke halaman sesuai role
          if (role == AppConstants.roleAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
            return;
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
            return;
          }
        }
      } catch (e) {
        print("Error auto-login: $e");
      }
    }

    // Jika belum login, matikan loading dan tampilkan slider Onboarding
    if (mounted) {
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

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
    // ── Tampilan Loading saat ngecek sesi ──
    if (_isCheckingSession) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 80),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppColors.primaryGreen),
            ],
          ),
        ),
      );
    }

    // ── Tampilan Slider Onboarding (kalau belum login) ──
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
                    AppTextButton(
                      label: "Lewati",
                      onPressed: _onSkipPressed,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    AppPrimaryButton(
                      width: 140, 
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