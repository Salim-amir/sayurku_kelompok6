import 'package:flutter/material.dart';
import 'core/colors.dart';
// Import kedua halaman auth kamu
import 'features/auth/login_screen.dart';
import 'features/auth/splash_screen.dart';

void main() {
  // Jika nanti sudah pakai Firebase, inisialisasi dilakukan di sini
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

      // UBAH BAGIAN INI:
      // Arahkan ke SplashScreen sebagai halaman pertama
      home: const SplashScreen(), 
      
      // Opsional: Kamu bisa mendaftarkan rute di sini agar navigasi lebih rapi
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}