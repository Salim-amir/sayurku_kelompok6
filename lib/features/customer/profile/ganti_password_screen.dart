import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';
import '../../../services/profile_service.dart';

class GantiPasswordScreen extends StatefulWidget {
  const GantiPasswordScreen({super.key});

  @override
  State<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<GantiPasswordScreen> {
  final ProfileService _profileService = ProfileService();
  final user = FirebaseAuth.instance.currentUser;

  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  bool _isLoading = false;
  bool _isResetLoading = false;
  bool _obscurePasswordLama = true;
  bool _obscurePasswordBaru = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _gantiPassword() async {
    final passwordLama = _passwordLamaController.text;
    final passwordBaru = _passwordBaruController.text;
    final konfirmasi = _konfirmasiController.text;

    // Validasi
    if (passwordLama.isEmpty) {
      _showSnackbar('Masukkan password lama', AppColors.warning);
      return;
    }
    if (passwordBaru.isEmpty) {
      _showSnackbar('Masukkan password baru', AppColors.warning);
      return;
    }
    if (passwordBaru.length < 6) {
      _showSnackbar('Password baru minimal 6 karakter', AppColors.warning);
      return;
    }
    if (passwordBaru != konfirmasi) {
      _showSnackbar('Konfirmasi password tidak cocok', AppColors.warning);
      return;
    }
    if (passwordLama == passwordBaru) {
      _showSnackbar(
          'Password baru tidak boleh sama dengan password lama', AppColors.warning);
      return;
    }

    setState(() => _isLoading = true);

    final error = await _profileService.gantiPassword(
      passwordLama: passwordLama,
      passwordBaru: passwordBaru,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (error != null) {
        _showSnackbar(error, AppColors.error);
      } else {
        _showSnackbar('Password berhasil diubah!', AppColors.success);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _kirimResetPassword() async {
    if (user?.email == null) {
      _showSnackbar('Email tidak ditemukan', AppColors.error);
      return;
    }

    setState(() => _isResetLoading = true);

    final error = await _profileService.kirimResetPassword(user!.email!);

    if (mounted) {
      setState(() => _isResetLoading = false);

      if (error != null) {
        _showSnackbar(error, AppColors.error);
      } else {
        _showSnackbar(
          'Link reset password telah dikirim ke ${user!.email}',
          AppColors.success,
        );
      }
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeaderIcon(),
                    const SizedBox(height: 24),
                    _buildPasswordForm(),
                    const SizedBox(height: 20),
                    _buildSimpanButton(),
                    const SizedBox(height: 24),
                    _buildDividerSection(),
                    const SizedBox(height: 20),
                    _buildResetViaEmailSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primaryGreen),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Ganti Password',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  // ── HEADER ICON ─────────────────────────────────────
  Widget _buildHeaderIcon() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: AppColors.primaryGreen,
            size: 40,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Buat password baru yang aman',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ── PASSWORD FORM ───────────────────────────────────
  Widget _buildPasswordForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPasswordField(
            label: 'PASSWORD LAMA',
            controller: _passwordLamaController,
            hint: 'Masukkan password lama',
            obscure: _obscurePasswordLama,
            onToggle: () =>
                setState(() => _obscurePasswordLama = !_obscurePasswordLama),
          ),
          const SizedBox(height: 18),
          _buildPasswordField(
            label: 'PASSWORD BARU',
            controller: _passwordBaruController,
            hint: 'Minimal 6 karakter',
            obscure: _obscurePasswordBaru,
            onToggle: () =>
                setState(() => _obscurePasswordBaru = !_obscurePasswordBaru),
          ),
          const SizedBox(height: 18),
          _buildPasswordField(
            label: 'KONFIRMASI PASSWORD BARU',
            controller: _konfirmasiController,
            hint: 'Ketik ulang password baru',
            obscure: _obscureKonfirmasi,
            onToggle: () =>
                setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: const Icon(Icons.lock_rounded,
                color: AppColors.textHint, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
              onPressed: onToggle,
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
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // ── SIMPAN BUTTON ──────────────────────────────────
  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _gantiPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
            : Text('Simpan Password Baru', style: AppTextStyles.buttonPrimary),
      ),
    );
  }

  // ── DIVIDER ────────────────────────────────────────
  Widget _buildDividerSection() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('ATAU',
              style: AppTextStyles.dividerLabel),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  // ── RESET VIA EMAIL ────────────────────────────────
  Widget _buildResetViaEmailSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.email_rounded,
              color: AppColors.info, size: 32),
          const SizedBox(height: 12),
          Text(
            'Lupa Password Lama?',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 6),
          Text(
            'Kami akan mengirim link reset password ke email Anda',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          if (user?.email != null)
            Text(
              user!.email!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: AppConstants.buttonHeightSM,
            child: OutlinedButton.icon(
              onPressed: _isResetLoading ? null : _kirimResetPassword,
              icon: _isResetLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.info,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _isResetLoading ? 'Mengirim...' : 'Kirim Link Reset',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: const BorderSide(color: AppColors.info),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
