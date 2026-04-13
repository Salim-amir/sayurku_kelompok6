import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          // Fungsi pop untuk kembali ke halaman Login tanpa menumpuk layar
          onPressed: () => Navigator.pop(context), 
        ),
        title: const Text(
          'SayurKu',
          style: AppTextStyles.appName, 
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Gambar Hero dengan efek Gradasi Memudar di bawahnya
            Stack(
              children: [
                Image.asset(
                  'assets/images/hero_vegetables.jpg', // Gambar sayur/wortel
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),
                // Gradasi dari transparan ke warna background aplikasi
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background.withValues(alpha: 0.0), // Transparan
                          AppColors.background, // Solid
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // 2. Konten Form (diberi padding agar ke tengah)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Buat Akun', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  const Text(
                    'Mulailah perjalanan hidup sehat dengan\nsayuran organik terbaik.',
                    style: AppTextStyles.appTagline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Field Nama Lengkap
                  const _NameTextField(),
                  const SizedBox(height: 16),

                  // Field Nomor HP
                  const _PhoneTextField(),
                  const SizedBox(height: 16),

                  // Field Kata Sandi
                  const _PasswordTextField(),
                  const SizedBox(height: 32),

                  // Tombol Daftar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        print('Daftar ditekan');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Daftar Sekarang', style: AppTextStyles.buttonPrimary),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Teks bawah (Login)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? ', style: AppTextStyles.labelLink),
                      InkWell(
                        onTap: () {
                          // Karena asalnya dari Login, kita cukup pop (tutup) halaman ini
                          Navigator.pop(context);
                        },
                        child: const Text('Masuk di sini', style: AppTextStyles.link),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets untuk TextField (Biar kodingan rapi) ──────────────

class _NameTextField extends StatelessWidget {
  const _NameTextField();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NAMA LENGKAP', style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.name,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: 'John Doe',
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textHint, size: 20),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }
}

class _PhoneTextField extends StatelessWidget {
  const _PhoneTextField();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NOMOR HP', style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.phone,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: '0812 XXXX XXXX',
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textHint, size: 20),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }
}

class _PasswordTextField extends StatelessWidget {
  const _PasswordTextField();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BUAT KATA SANDI', style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          obscureText: true,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 18),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textHint, size: 20),
            suffixIcon: const Icon(Icons.visibility_outlined, color: AppColors.textHint, size: 20),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }
}