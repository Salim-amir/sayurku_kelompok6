import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import '../customer/shop/home_screen.dart';
import '../../admin/dashboard/dashboard_admin_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Navigasi berdasarkan role ─────────────────────────────────────────
  void _navigasiByRole(String role) {
    if (role == AppConstants.roleAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // ─── Proses Login Email ────────────────────────────────────────────────
  Future<void> _prosesLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi harus diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // loginUser sekarang return LoginResult bukan String?
    final LoginResult result = await AuthService().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.error != null) {
      // Gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      // Sukses → arahkan berdasarkan role
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil Masuk!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      _navigasiByRole(result.role!);
    }
  }

  // ─── Proses Login Google ───────────────────────────────────────────────
  Future<void> _prosesLoginGoogle() async {
    setState(() => _isLoading = true);

    // Google selalu customer, tidak perlu cek role
    final String? error = await AuthService().loginWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil masuk dengan Google!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      // Google login hanya untuk customer
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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

              AppTextField(
                controller: _emailController,
                label: 'ALAMAT EMAIL',
                hintText: 'nama@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppConstants.paddingMD),

              AppPasswordField(
                controller: _passwordController,
                label: 'KATA SANDI',
                hintText: '••••••••••',
                trailingAction: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
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

              AppGoogleButton(onPressed: _prosesLoginGoogle),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: const Text('Daftar Sekarang', style: AppTextStyles.link),
        ),
      ],
    );
  }
}
