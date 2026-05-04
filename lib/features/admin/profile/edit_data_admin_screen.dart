import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan import Firestore
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';
import '../../../services/profile_service.dart';

class EditDataAdminScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditDataAdminScreen({super.key, required this.userData});

  @override
  State<EditDataAdminScreen> createState() => _EditDataAdminScreenState();
}

class _EditDataAdminScreenState extends State<EditDataAdminScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final ProfileService _profileService = ProfileService();

  late TextEditingController _namaController;
  late TextEditingController _hpController;
  late TextEditingController _emailController;

  bool _isLoading = false;
  bool _emailChanged = false;
  late String _originalEmail;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.userData['namaLengkap'] ?? '',
    );
    _hpController = TextEditingController(
      text: widget.userData['nomorHp'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? '',
    );

    _originalEmail = widget.userData['email'] ?? '';

    _emailController.addListener(() {
      setState(() {
        _emailChanged = _emailController.text.trim() != _originalEmail;
      });
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    final nama = _namaController.text.trim();
    final noHp = _hpController.text.trim();

    // 1. Validasi Nama Wajib Isi
    if (nama.isEmpty) {
      _showSnackbar('Nama lengkap tidak boleh kosong', AppColors.warning);
      return;
    }

    // 2. Validasi Nomor HP Opsional Tapi Bersyarat
    if (noHp.isNotEmpty) {
      if (!RegExp(r'^[0-9]+$').hasMatch(noHp)) {
        _showSnackbar('Nomor HP hanya boleh berisi angka', AppColors.warning);
        return;
      }
      if (!noHp.startsWith('08')) {
        _showSnackbar('Nomor HP harus diawali dengan "08"', AppColors.warning);
        return;
      }
      if (noHp.length < 10 || noHp.length > 13) {
        _showSnackbar(
          'Nomor HP harus terdiri dari 10 - 13 angka',
          AppColors.warning,
        );
        return;
      }
    }

    // 3. Proses Update Email (Tetap pakai service lama karena butuh re-auth password)
    if (_emailChanged) {
      final password = await _showPasswordDialog();
      if (password == null) return;

      setState(() => _isLoading = true);

      final emailError = await _profileService.updateEmail(
        newEmail: _emailController.text.trim(),
        password: password,
      );

      if (emailError != null) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackbar(emailError, AppColors.error);
        }
        return;
      }
    } else {
      setState(() => _isLoading = true);
    }

    try {
      if (user != null) {
        await FirebaseFirestore.instance
            .collection(
              AppConstants.colUsers,
            ) // Menyimpan ke koleksi admin/user
            .doc(user!.uid)
            .update({
              'namaLengkap': nama,
              'nomorHp':
                  noHp, // Kalau kosong, string kosong ('') yang tersimpan
            });

        if (mounted) {
          setState(() => _isLoading = false);
          final msg = _emailChanged
              ? 'Profil diperbarui! Cek email baru untuk verifikasi.'
              : 'Profil berhasil diperbarui!';
          _showSnackbar(msg, AppColors.success);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackbar(
          'Gagal menyimpan profil: ${e.toString()}',
          AppColors.error,
        );
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    bool obscure = true;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Verifikasi', style: AppTextStyles.h3),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan password Anda untuk mengubah email',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscure,
                autofocus: true,
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: AppTextStyles.inputHint,
                  prefixIcon: const Icon(
                    Icons.lock_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: Text(
                'Batal',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text.isEmpty) return;
                Navigator.pop(ctx, passwordController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Konfirmasi',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 28),
                    _buildForm(),
                    if (_emailChanged) ...[
                      const SizedBox(height: 12),
                      _buildEmailWarning(),
                    ],
                    const SizedBox(height: 28),
                    _buildSimpanButton(),
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
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primaryGreen,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Edit Profil',
            style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
          ),
        ],
      ),
    );
  }

  // ── AVATAR ──────────────────────────────────────────
  Widget _buildAvatar() {
    final nama = _namaController.text;
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.accentGreen.withOpacity(0.15),
          child: Text(
            nama.isNotEmpty ? nama[0].toUpperCase() : '?',
            style: AppTextStyles.h1.copyWith(
              color: AppColors.primaryGreen,
              fontSize: 36,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ubah data profil Anda',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── FORM ────────────────────────────────────────────
  Widget _buildForm() {
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
          _buildTextField(
            label: 'NAMA LENGKAP',
            controller: _namaController,
            icon: Icons.person_rounded,
            hint: 'Masukkan nama lengkap',
          ),
          const SizedBox(height: 18),
          _buildTextField(
            label: 'NOMOR HP (OPSIONAL)',
            controller: _hpController,
            icon: Icons.phone_android_rounded,
            hint: '08xx xxxx xxxx',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          _buildTextField(
            label: 'EMAIL',
            controller: _emailController,
            icon: Icons.email_rounded,
            hint: 'email@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  // ── EMAIL CHANGE WARNING ───────────────────────────
  Widget _buildEmailWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mengubah email memerlukan verifikasi password. Email baru perlu diverifikasi.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          style: AppTextStyles.inputText.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textHint,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: Icon(
              icon,
              color: enabled ? AppColors.textHint : AppColors.divider,
              size: 20,
            ),
            filled: true,
            fillColor: enabled ? AppColors.inputBackground : AppColors.divider,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
        onPressed: _isLoading ? null : _simpanPerubahan,
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
            : Text('Simpan Perubahan', style: AppTextStyles.buttonPrimary),
      ),
    );
  }
}
