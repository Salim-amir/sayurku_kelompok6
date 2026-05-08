import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';
import '../../../services/profile_service.dart';

class EditProfilScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilScreen({super.key, required this.userData});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final ProfileService _profileService = ProfileService();

  late TextEditingController _namaController;
  late TextEditingController _hpController;
  late TextEditingController _emailController;

  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  bool _emailChanged = false;
  late String _originalEmail;
  File? _selectedImage;
  String _currentFotoUrl = '';

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.userData['namaLengkap'] ?? '');
    _hpController =
        TextEditingController(text: widget.userData['nomorHp'] ?? '');
    _emailController =
        TextEditingController(text: widget.userData['email'] ?? '');

    _originalEmail = widget.userData['email'] ?? '';
    _currentFotoUrl = widget.userData['fotoUrl'] ?? '';

    // Listener untuk deteksi perubahan email
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
    if (_namaController.text.trim().isEmpty) {
      _showSnackbar('Nama lengkap tidak boleh kosong', AppColors.warning);
      return;
    }

    if (_hpController.text.trim().isEmpty) {
      _showSnackbar('Nomor HP tidak boleh kosong', AppColors.warning);
      return;
    }

    // Jika email berubah, minta password untuk re-auth
    if (_emailChanged) {
      final password = await _showPasswordDialog();
      if (password == null) return; // User batal

      setState(() => _isLoading = true);

      // Update email dulu (butuh re-auth)
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

    // Update nama & no HP
    final error = await _profileService.updateProfil(
      uid: user!.uid,
      namaLengkap: _namaController.text.trim(),
      nomorHp: _hpController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (error != null) {
        _showSnackbar(error, AppColors.error);
      } else {
        final msg = _emailChanged
            ? 'Profil diperbarui! Cek email baru untuk verifikasi.'
            : 'Profil berhasil diperbarui!';
        _showSnackbar(msg, AppColors.success);
        Navigator.pop(context);
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.security_rounded,
                    color: AppColors.warning, size: 20),
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
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
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
                    onPressed: () =>
                        setDialogState(() => obscure = !obscure),
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
                        color: AppColors.primaryGreen, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: Text('Batal',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
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
              child: Text('Konfirmasi',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
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

  // ── AVATAR WITH PHOTO PICKER ───────────────────────────
  Widget _buildAvatar() {
    final nama = _namaController.text;
    return Column(
      children: [
        GestureDetector(
          onTap: _showPhotoOptions,
          child: Stack(
            children: [
              // Avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.accentGreen.withOpacity(0.15),
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_currentFotoUrl.isNotEmpty
                        ? NetworkImage(_currentFotoUrl) as ImageProvider
                        : null),
                child: (_selectedImage == null && _currentFotoUrl.isEmpty)
                    ? Text(
                        nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primaryGreen,
                          fontSize: 36,
                        ),
                      )
                    : null,
              ),
              // Camera badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isUploadingPhoto
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.white),
                        )
                      : const Icon(Icons.camera_alt_rounded,
                          color: AppColors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ketuk foto untuk mengubah',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Foto Profil', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  color: AppColors.primaryGreen,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildPhotoOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_currentFotoUrl.isNotEmpty || _selectedImage != null)
                  _buildPhotoOption(
                    icon: Icons.delete_rounded,
                    label: 'Hapus',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(ctx);
                      _hapusFoto();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);
      setState(() => _selectedImage = imageFile);

      // Upload langsung
      await _uploadFoto(imageFile);
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal memilih foto: $e', AppColors.error);
      }
    }
  }

  Future<void> _uploadFoto(File file) async {
    setState(() => _isUploadingPhoto = true);

    final error = await _profileService.uploadFotoProfil(
      uid: user!.uid,
      imageFile: file,
    );

    if (mounted) {
      setState(() => _isUploadingPhoto = false);
      if (error != null) {
        _showSnackbar(error, AppColors.error);
        setState(() => _selectedImage = null); // revert
      } else {
        _showSnackbar('Foto profil berhasil diperbarui!', AppColors.success);
      }
    }
  }

  Future<void> _hapusFoto() async {
    setState(() => _isUploadingPhoto = true);

    final error = await _profileService.hapusFotoProfil(uid: user!.uid);

    if (mounted) {
      setState(() {
        _isUploadingPhoto = false;
        if (error == null) {
          _selectedImage = null;
          _currentFotoUrl = '';
        }
      });
      _showSnackbar(
        error ?? 'Foto profil dihapus', error != null ? AppColors.error : AppColors.success);
    }
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
          const Icon(Icons.info_outline_rounded,
              color: AppColors.warning, size: 20),
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
