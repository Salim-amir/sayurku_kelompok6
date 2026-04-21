import '../customer/shop/home_screen.dart';
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../../services/auth_service.dart'; // Buka komen ini kalau Auth sudah siap dipanggil

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk menangkap teks (Kita pakai Email karena Firebase Auth butuh Email)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _prosesLogin() async {
    // 1. Cek apakah ada kolom yang kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi harus diisi!')),
      );
      return;
    }

    // 2. Nyalakan efek muter-muter (loading)
    setState(() => _isLoading = true);

    // 3. Panggil mesin Firebase yang baru saja kita buat di Langkah 1!
    String? pesanError = await AuthService().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // 4. Matikan efek loading
    setState(() => _isLoading = false);

    // 5. Cek Hasilnya
    if (pesanError == null) {
      // SUKSES LOGIN
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil Masuk!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      // MENGHANCURKAN HALAMAN LOGIN DAN PINDAH KE HOME
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // GAGAL LOGIN (Munculkan pop-up merah dari bawah)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesanError), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLG,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppConstants.paddingXL),
              _buildLogo(),
              const SizedBox(height: AppConstants.paddingLG),
              _buildHeroImage(),
              const SizedBox(height: 28),
              _buildWelcomeText(),
              const SizedBox(height: 28),

              // ─── PENGGUNAAN CUSTOM WIDGET ───
              AppTextField(
                controller: _emailController,
                label: 'ALAMAT EMAIL',
                hintText: 'nama@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppConstants.paddingMD),

              AppPasswordField(
                controller: _passwordController,
                label: 'KATA SANDI',
                hintText: '••••••••••',
                trailingAction: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Lupa Sandi?',
                    style: AppTextStyles.linkUppercase,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onEditingComplete: _prosesLogin,
              ),
              const SizedBox(height: 28),

              AppPrimaryButton(
                label: 'Masuk',
                isLoading: _isLoading,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: _prosesLogin,
              ),
              const SizedBox(height: AppConstants.paddingLG),

              _buildDivider(),
              const SizedBox(height: 20),

              // Cukup panggil AppGoogleButton!
              AppGoogleButton(
                onPressed: () async {
                  setState(() => _isLoading = true); // Nyalakan loading

                  final pesanError = await AuthService().loginWithGoogle();

                  // Pastikan widget masih ada sebelum lanjut
                  if (!mounted) return;

                  setState(() => _isLoading = false); // Matikan loading

                  if (pesanError == null) {
                    // Sukses
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Berhasil masuk dengan Google!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  } else {
                    // Gagal / Batal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(pesanError),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 28),

              _buildRegisterRow(context),
              const SizedBox(height: AppConstants.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.inputBackground,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.eco_rounded,
            color: AppColors.primaryGreen,
            size: AppConstants.iconXL,
          ),
        ),
        const SizedBox(height: 10),
        const Text(AppConstants.appName, style: AppTextStyles.appName),
        const SizedBox(height: 4),
        const Text(AppConstants.appTagline, style: AppTextStyles.appTagline),
      ],
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      child: Image.asset(
        AppConstants.heroImage,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Selamat Datang', style: AppTextStyles.h1),
        SizedBox(height: 6),
        Text(
          'Masuk untuk mulai belanja bahan segar',
          style: AppTextStyles.appTagline,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMD),
          child: Text('ATAU', style: AppTextStyles.dividerLabel),
        ),
        Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }

  Widget _buildRegisterRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Belum punya akun? ', style: AppTextStyles.labelLink),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: const Text('Daftar Sekarang', style: AppTextStyles.link),
        ),
      ],
    );
  }
}
