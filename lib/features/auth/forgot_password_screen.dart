import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Membuat AppBar dengan tombol kembali (Back Arrow)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(
            context,
          ), // Fungsi untuk kembali ke halaman sebelumnya
        ),
        title: Text(
          'Reset Password',
          style: AppTextStyles.h1.copyWith(
            fontSize: 18,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Ikon Reset (Lingkaran gembok)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGreen, width: 3),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primaryGreen,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),

              const Text('Lupa Kata Sandi', style: AppTextStyles.h1),
              const SizedBox(height: 12),
              const Text(
                'Masukkan nomor HP terdaftar untuk\nreset kata sandi',
                style: AppTextStyles.appTagline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // TextField Nomor HP
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nomor HP', style: AppTextStyles.labelLink),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.phone,
                    style: AppTextStyles.inputText,
                    decoration: InputDecoration(
                      hintText: '0812xxxx',
                      hintStyle: AppTextStyles.inputHint,
                      prefixIcon: const Icon(
                        Icons.phone_android_rounded,
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Tombol Kirim Link
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    print('Kirim Link Reset ditekan');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Kirim Link Reset',
                        style: AppTextStyles.buttonPrimary,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Teks Bawah
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Butuh bantuan lain? ',
                    style: AppTextStyles.labelLink,
                  ),
                  GestureDetector(
                    onTap: () {
                      print('Hubungi Kami ditekan');
                    },
                    child: const Text(
                      'Hubungi Kami',
                      style: AppTextStyles.link,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
