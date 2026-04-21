import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';

class EditProfilScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilScreen({super.key, required this.userData});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late TextEditingController _namaController;
  late TextEditingController _hpController;
  late TextEditingController _emailController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.userData['namaLengkap'] ?? '');
    _hpController =
        TextEditingController(text: widget.userData['nomorHp'] ?? '');
    _emailController =
        TextEditingController(text: widget.userData['email'] ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    if (_namaController.text.trim().isEmpty) {
      _showSnackbar('Nama lengkap tidak boleh kosong', AppColors.warning);
      return;
    }

    if (_hpController.text.trim().isEmpty) {
      _showSnackbar('Nomor HP tidak boleh kosong', AppColors.warning);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.colUsers)
          .doc(user!.uid)
          .update({
        'namaLengkap': _namaController.text.trim(),
        'nomorHp': _hpController.text.trim(),
      });

      if (mounted) {
        _showSnackbar('Profil berhasil diperbarui!', AppColors.success);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal menyimpan: ${e.toString()}', AppColors.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    _buildAvatar(),
                    const SizedBox(height: 28),
                    _buildForm(),
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
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primaryGreen),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Edit Profil',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
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
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
            label: 'NOMOR HP',
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
            enabled: false, // Email tidak bisa diubah
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
            prefixIcon: Icon(icon,
                color: enabled ? AppColors.textHint : AppColors.divider,
                size: 20),
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
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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
