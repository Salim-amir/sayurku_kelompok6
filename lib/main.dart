import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'core/colors.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/customer/shop/home_screen.dart';
import 'features/customer/profile/profile_screen.dart';
import 'features/customer/profile/riwayat_pesanan_screen.dart';
import 'features/customer/profile/dompet_digital_screen.dart';
import 'features/customer/profile/isi_saldo_screen.dart';
import 'features/customer/profile/alamat_screen.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SayurKu',
      
      // Tema Global Aplikasi
      theme: ThemeData(
        fontFamily: 'Manrope', // Pastikan sudah di-setup di pubspec.yaml
        scaffoldBackgroundColor: AppColors.background, 
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
      ),
home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/riwayat-pesanan': (context) => const RiwayatPesananScreen(),
        '/dompet': (context) => const DompetDigitalScreen(),
        '/isi-saldo': (context) => const IsiSaldoScreen(),
        '/alamat': (context) => const AlamatScreen(),
      },
    );
  }
}