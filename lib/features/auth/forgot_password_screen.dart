import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ─── GANTI JADI EMAIL CONTROLLER ───
  final TextEditingController _emailController = TextEditingController();

  // ─── State ───
  bool _isLoading = false;
  String? _errorText;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ─── Validasi Email ───
  String? _validateEmail(String value) {
    if (value.trim().isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    if (!value.contains('@')) {
      return 'Format email tidak valid (harus mengandung @).';
    }
    return null;
  }

  // ─── Fungsi Kirim Reset ───
  Future<void> _kirimReset() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();

    final validasiError = _validateEmail(email);
    if (validasiError != null) {
      setState(() => _errorText = validasiError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // Panggil mesin AuthService yang baru
    final error = await AuthService().resetPassword(email: email);
    
    // Pakai context.mounted biar ga ada garis biru
    if (!context.mounted) return; 

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorText = error);
    } else {
      setState(() => _isSent = true);
      _tampilkanSnackbar(
        'Link reset berhasil dikirim ke email Anda.',
        isError: false,
      );
    }
  }

  // ─── Helper Snackbar ───
  void _tampilkanSnackbar(String pesan, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pesan,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
        ),
        margin: const EdgeInsets.all(AppConstants.paddingMD),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLG,
          ),
          child: _isSent ? _buildSuksesView() : _buildFormView(),
        ),
      ),
    );
  }

  // ─── View: Form Input ───
  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),

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
          'Masukkan alamat email terdaftar untuk\nreset kata sandi',
          style: AppTextStyles.appTagline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // ── Input Email ──
        AppTextField(
          label: 'ALAMAT EMAIL',
          hintText: 'nama@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          errorText: _errorText,
          enabled: !_isLoading,
          onChanged: (_) {
            if (_errorText != null) setState(() => _errorText = null);
          },
        ),
        const SizedBox(height: 32),

        AppPrimaryButton(
          label: 'Kirim Link Reset',
          onPressed: _kirimReset,
          isLoading: _isLoading,
          trailingIcon: Icons.send_rounded,
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  // ─── View: Sukses ───
  Widget _buildSuksesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.white,
            size: 52,
          ),
        ),
        const SizedBox(height: 32),

        const Text('Link Terkirim!', style: AppTextStyles.h1),
        const SizedBox(height: 12),
        const Text(
          'Link reset kata sandi telah dikirim\nke email yang terdaftar.\nSilakan cek inbox atau folder spam.',
          style: AppTextStyles.appTagline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        AppPrimaryButton(
          label: 'Kembali ke Login',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 16),

        AppTextButton(
          label: 'Gunakan email berbeda',
          onPressed: () => setState(() {
            _isSent = false;
            _emailController.clear();
          }),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}