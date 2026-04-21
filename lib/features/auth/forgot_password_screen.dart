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
  // ─── Controller & Service ─────────────────────────────────────────────────
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  // ─── State ────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorText;
  bool _isSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ─── Validasi Nomor HP ────────────────────────────────────────────────────
  String? _validatePhone(String value) {
    if (value.trim().isEmpty) {
      return 'Nomor HP tidak boleh kosong.';
    }
    if (!value.startsWith('08') && !value.startsWith('+62')) {
      return 'Nomor HP harus diawali 08 atau +62.';
    }
    if (value.trim().length < 10 || value.trim().length > 14) {
      return 'Nomor HP tidak valid.';
    }
    return null;
  }

  // ─── Fungsi Kirim Reset ───────────────────────────────────────────────────
  Future<void> _kirimReset() async {
    FocusScope.of(context).unfocus();

    final phone = _phoneController.text.trim();

    final validasiError = _validatePhone(phone);
    if (validasiError != null) {
      setState(() => _errorText = validasiError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final error = await _authService.resetPassword(nomorHp: phone);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorText = error);
    } else {
      setState(() => _isSent = true);
      _tampilkanSnackbar(
        'Link reset berhasil dikirim ke email terdaftar.',
        isError: false,
      );
    }
  }

  // ─── Helper Snackbar ──────────────────────────────────────────────────────
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

  // ─── View: Form Input ─────────────────────────────────────────────────────
  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),

        // Ikon reset
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

        // ── Pakai AppTextField ──
        AppTextField(
          label: 'NOMOR HP',
          hintText: '0812xxxx',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_android_rounded,
          errorText: _errorText,
          enabled: !_isLoading,
          onChanged: (_) {
            if (_errorText != null) setState(() => _errorText = null);
          },
        ),
        const SizedBox(height: 32),

        // ── Pakai AppPrimaryButton ──
        AppPrimaryButton(
          label: 'Kirim Link Reset',
          onPressed: _kirimReset,
          isLoading: _isLoading,
          trailingIcon: Icons.send_rounded,
        ),
        const SizedBox(height: 48),

        // Bantuan — pakai AppTextButton
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Butuh bantuan lain? ', style: AppTextStyles.labelLink),
            AppTextButton(
              label: 'Hubungi Kami',
              onPressed: () => print('Hubungi Kami ditekan'),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ─── View: Sukses ─────────────────────────────────────────────────────────
  Widget _buildSuksesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        // Ikon centang
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

        // ── Pakai AppPrimaryButton ──
        AppPrimaryButton(
          label: 'Kembali ke Login',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 16),

        // ── Pakai AppTextButton ──
        AppTextButton(
          label: 'Kirim ulang dengan nomor berbeda',
          onPressed: () => setState(() {
            _isSent = false;
            _phoneController.clear();
          }),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}