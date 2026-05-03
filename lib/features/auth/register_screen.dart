import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../services/auth_service.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); 
    super.dispose();
  }

  void _prosesDaftar() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua data!')),
      );
      return;
    }

    // ── Validasi nomor HP ──────────────────────────────────────────
    final phone = _phoneController.text.trim();
    if (!phone.startsWith('08')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor HP harus diawali dengan 08!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (phone.length < 10 || phone.length > 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor HP harus 10–13 digit!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? pesanError = await AuthService().registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      namaLengkap: _nameController.text.trim(),
      nomorHp: phone,
    );

    setState(() => _isLoading = false);

    if (pesanError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat! Silakan masuk.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      if (mounted) Navigator.pop(context);
    } else {
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

                  _NameTextField(controller: _nameController),
                  const SizedBox(height: 16),

                  _EmailTextField(controller: _emailController),
                  const SizedBox(height: 16),

                  // ── Kirim controller password agar bisa validasi live ──
                  _PhoneTextField(controller: _phoneController),
                  const SizedBox(height: 16),

                  _PasswordTextField(controller: _passwordController),
                  const SizedBox(height: 32),

                  _ConfirmPasswordTextField(
                    controller: _confirmPasswordController,
                    originalPasswordController: _passwordController,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _prosesDaftar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor:
                            AppColors.primaryGreen.withValues(alpha: 0.6),
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
                                Text('Daftar Sekarang',
                                    style: AppTextStyles.buttonPrimary),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 20, color: Colors.white),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? ',
                          style: AppTextStyles.labelLink),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Masuk di sini',
                            style: AppTextStyles.link),
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

// ─── SUB-WIDGETS ──────────────────────────────────────────────────────────

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

// ─── PHONE TEXT FIELD — dengan validasi 08 & maks 13 digit ───────────────
class _PhoneTextField extends StatefulWidget {
  final TextEditingController controller;
  const _PhoneTextField({required this.controller});

  @override
  State<_PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<_PhoneTextField> {
  String? _errorText;

  void _validate(String value) {
    String? error;

    if (value.isEmpty) {
      error = null; // Biarkan kosong — validasi utama di tombol Daftar
    } else if (!value.startsWith('08')) {
      error = 'Nomor HP harus diawali dengan 08';
    } else if (value.length > 13) {
      error = 'Nomor HP maksimal 13 digit';
    } else if (value.length < 10) {
      error = 'Nomor HP minimal 10 digit';
    }

    setState(() => _errorText = error);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NOMOR HP', style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.phone,
          style: AppTextStyles.inputText,
          // ── Hanya angka, maks 13 karakter ─────────────────────
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
          ],
          onChanged: _validate,
          decoration: InputDecoration(
            hintText: '08xx xxxx xxxx',
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: const Icon(Icons.phone_outlined,
                color: AppColors.textHint, size: 20),
            filled: true,
            fillColor: AppColors.inputBackground,
            // Garis tepi merah kalau ada error
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: _errorText != null
                  ? const BorderSide(color: AppColors.error, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    _errorText != null ? AppColors.error : AppColors.primaryGreen,
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            // Pesan error inline di bawah field
            errorText: _errorText,
            errorStyle: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
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
  double _strengthScore = 0.0;
  Color _strengthColor = Colors.transparent;
  String _strengthText = '';

  void _checkPasswordStrength(String value) {
    if (value.isEmpty) {
      setState(() {
        _strengthScore = 0.0;
        _strengthText = '';
        _strengthColor = Colors.transparent;
      });
      return;
    }

    double score = 0.0;
    if (value.length >= 6) score += 0.33;
    if (value.length >= 8) score += 0.33;
    if (value.contains(RegExp(r'[a-zA-Z]')) &&
        value.contains(RegExp(r'[0-9]'))) {
      score += 0.34;
    }

    setState(() {
      _strengthScore = score;
      if (score <= 0.33) {
        _strengthColor = AppColors.error;
        _strengthText = 'Lemah';
      } else if (score <= 0.66) {
        _strengthColor = Colors.orange;
        _strengthText = 'Sedang';
      } else {
        _strengthColor = AppColors.primaryGreen;
        _strengthText = 'Kuat';
      }
    });
  }

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
          onChanged: _checkPasswordStrength,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 18),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.textHint, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
              onPressed: () => setState(() => _isObscured = !_isObscured),
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
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
        if (_strengthText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 4.0, right: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _strengthScore,
                      backgroundColor: AppColors.inputBorder,
                      color: _strengthColor,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 50,
                  child: Text(
                    _strengthText,
                    style: TextStyle(
                      color: _strengthColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

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
      borderSide:
          const BorderSide(color: AppColors.primaryGreen, width: 1.5),
    ),
    contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  );
}

class _ConfirmPasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController originalPasswordController;

  const _ConfirmPasswordTextField({
    super.key,
    required this.controller,
    required this.originalPasswordController,
  });

  @override
  State<_ConfirmPasswordTextField> createState() =>
      _ConfirmPasswordTextFieldState();
}

class _ConfirmPasswordTextFieldState
    extends State<_ConfirmPasswordTextField> {
  bool _isObscured = true;
  String _matchText = '';
  Color _matchColor = Colors.transparent;

  void _checkMatch(String value) {
    if (value.isEmpty) {
      setState(() {
        _matchText = '';
        _matchColor = Colors.transparent;
      });
      return;
    }
    if (value == widget.originalPasswordController.text) {
      setState(() {
        _matchText = 'Sandi Cocok';
        _matchColor = AppColors.primaryGreen;
      });
    } else {
      setState(() {
        _matchText = 'Sandi Tidak Cocok';
        _matchColor = AppColors.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('KONFIRMASI KATA SANDI',
            style: AppTextStyles.labelUppercase),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _isObscured,
          onChanged: _checkMatch,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 18),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.textHint, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
              onPressed: () => setState(() => _isObscured = !_isObscured),
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
              borderSide: BorderSide(
                color: _matchColor == Colors.transparent
                    ? AppColors.primaryGreen
                    : _matchColor,
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
        if (_matchText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Row(
              children: [
                Icon(
                  _matchText == 'Sandi Cocok'
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: _matchColor,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _matchText,
                  style: TextStyle(
                    color: _matchColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}