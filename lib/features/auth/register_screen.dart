import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../services/auth_service.dart'; // Import service Firebase kita

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Siapkan Controller untuk menangkap teks
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Variabel Loading
  bool _isLoading = false;

  // Jangan lupa matikan controller kalau layar ditutup biar memori HP nggak bocor
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 3. Fungsi Utama Mendaftar ke Firebase
  void _prosesDaftar() async {
    // A. Cek apakah ada kolom yang kosong
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap isi semua data!')));
      return;
    }

    // B. Nyalakan efek loading
    setState(() {
      _isLoading = true;
    });

    // C. Panggil AuthService
    String? pesanError = await AuthService().registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      namaLengkap: _nameController.text.trim(),
      nomorHp: _phoneController.text.trim(),
    );

    // D. Matikan efek loading
    setState(() {
      _isLoading = false;
    });

    // E. Cek Hasilnya
    if (pesanError == null) {
      // SUKSES! Tampilkan pesan dan tutup layar daftar (kembali ke Login)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat! Silakan masuk.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      if (mounted) Navigator.pop(context);
    } else {
      // GAGAL! Tampilkan pesan error dari Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesanError), backgroundColor: Colors.red),
      );
    }
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('SayurKu', style: AppTextStyles.appName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/hero_carrots.png',
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),
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
                          AppColors.background.withValues(alpha: 0.0),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

                  // Masukkan controller ke masing-masing sub-widget
                  _NameTextField(controller: _nameController),
                  const SizedBox(height: 16),

                  // NEW: Field Email
                  _EmailTextField(controller: _emailController),
                  const SizedBox(height: 16),

                  _PhoneTextField(controller: _phoneController),
                  const SizedBox(height: 16),

                  _PasswordTextField(controller: _passwordController),
                  const SizedBox(height: 32),

                  // Tombol Daftar (Bisa berubah jadi Loading)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      // Jika lagi loading, matikan tombol (null)
                      onPressed: _isLoading ? null : _prosesDaftar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // Biar warnanya agak pudar kalau tombol dimatikan
                        disabledBackgroundColor: AppColors.primaryGreen
                            .withValues(alpha: 0.6),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Daftar Sekarang',
                                  style: AppTextStyles.buttonPrimary,
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: AppTextStyles.labelLink,
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Masuk di sini',
                          style: AppTextStyles.link,
                        ),
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

// ─── SUB-WIDGETS ───────────────────────────────────────────────

class _NameTextField extends StatelessWidget {
  final TextEditingController controller;
  const _NameTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NAMA LENGKAP', style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.name,
          style: AppTextStyles.inputText,
          decoration: _buildInputDecoration(
            hintText: 'John Doe',
            icon: Icons.person_outline_rounded,
          ),
        ),
      ],
    );
  }
}

// Sub-widget baru untuk Email
class _EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ALAMAT EMAIL', style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.inputText,
          decoration: _buildInputDecoration(
            hintText: 'john@gmail.com',
            icon: Icons.email_outlined,
          ),
        ),
      ],
    );
  }
}

class _PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NOMOR HP', style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: AppTextStyles.inputText,
          decoration: _buildInputDecoration(
            hintText: '0812 XXXX XXXX',
            icon: Icons.phone_outlined,
          ),
        ),
      ],
    );
  }
}

class _PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordTextField({required this.controller});

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BUAT KATA SANDI', style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _isObscured,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 18),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
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
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}

// Fungsi pembantu agar kodingan dekorasi TextField tidak berulang-ulang
InputDecoration _buildInputDecoration({
  required String hintText,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.inputHint,
    prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
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
      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  );
}
