import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';

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
  bool _isSent = false; // Menandai link sudah berhasil dikirim

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
    // Tutup keyboard
    FocusScope.of(context).unfocus();

    final phone = _phoneController.text.trim();

    // Validasi lokal dulu
    final validasiError = _validatePhone(phone);
    if (validasiError != null) {
      setState(() => _errorText = validasiError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // Panggil service
    final error = await _authService.resetPassword(nomorHp: phone);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      // Gagal → tampilkan error di bawah field
      setState(() => _errorText = error);
    } else {
      // Berhasil → tampilkan state sukses
      setState(() => _isSent = true);
      _tampilkanSnackbar(
        'Link reset berhasil dikirim ke email terdaftar.',
        isError: false,
      );
    }
  }

  // ─── Helper Snackbar ─────────────────────────────────────────────────────
  void _tampilkanSnackbar(String pesan, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
        )),
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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

        // TextField Nomor HP
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nomor HP', style: AppTextStyles.labelLink),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.inputText,
              enabled: !_isLoading,
              onChanged: (_) {
                // Hapus error saat user mulai mengetik ulang
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              decoration: InputDecoration(
                hintText: '0812xxxx',
                hintStyle: AppTextStyles.inputHint,
                errorText: _errorText,
                errorStyle: AppTextStyles.caption.copyWith(
                  color: Colors.redAccent,
                ),
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
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Tombol Kirim
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _kirimReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Kirim Link Reset',
                        style: AppTextStyles.buttonPrimary,
                      ),
                      SizedBox(width: 8),
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

        // Bantuan
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Butuh bantuan lain? ', style: AppTextStyles.labelLink),
            GestureDetector(
              onTap: () => print('Hubungi Kami ditekan'),
              child: const Text('Hubungi Kami', style: AppTextStyles.link),
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

        // Tombol kembali ke login
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Kembali ke Login',
              style: AppTextStyles.buttonPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Kirim ulang
        GestureDetector(
          onTap: () => setState(() {
            _isSent = false;
            _phoneController.clear();
          }),
          child: const Text(
            'Kirim ulang dengan nomor berbeda',
            style: AppTextStyles.link,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}