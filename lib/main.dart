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
import 'features/customer/profile/ganti_password_screen.dart';
import 'features/admin/dashboard/dashboard_admin_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/cart_manager.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Menerima pesan saat aplikasi ditutup: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await CartManager.instance.init();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/profile': (context) => const ProfileScreen(),
        '/riwayat-pesanan': (context) => const RiwayatPesananScreen(),
        '/dompet': (context) => const DompetDigitalScreen(),
        '/isi-saldo': (context) => const IsiSaldoScreen(),
        '/alamat': (context) => const AlamatScreen(),
        '/ganti-password': (context) => const GantiPasswordScreen(),
      },
    );
  }
}
