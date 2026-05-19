import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _prosesDaftar() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackbar('Harap isi semua data!', AppColors.error);
      return;
    }

    final phone = _phoneController.text.trim();
    if (!phone.startsWith('08')) {
      _showSnackbar('Nomor HP harus diawali dengan 08!', AppColors.error);
      return;
    }
    if (phone.length < 10 || phone.length > 13) {
      _showSnackbar('Nomor HP harus 10–13 digit!', AppColors.error);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackbar('Kata sandi tidak cocok!', AppColors.error);
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
      _showSnackbar('Akun berhasil dibuat! Silakan masuk.', AppColors.success);
      if (mounted) Navigator.pop(context);
    } else {
      _showSnackbar(pesanError, AppColors.error);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D2B1A),
      body: Stack(
        children: [
          // ── Background dekorasi (sama persis dengan login) ──
          _buildBackground(size),

          // ── Konten utama ──
          SafeArea(
            child: Column(
              children: [
                // ── AppBar custom ──
                _buildAppBar(),

                // ── Scrollable content ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildHeaderSection(),
                            const SizedBox(height: 20),
                            _buildFormCard(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Background blobs — identik dengan login ──────────────────────────────
  Widget _buildBackground(Size size) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen.withOpacity(0.18),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.3,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width, 140),
              painter: _ArcPainter(),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar custom ────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            AppConstants.appName,
            style: AppTextStyles.appName.copyWith(color: Colors.white),
          ),
          const Spacer(),
          const SizedBox(width: 48), // balance back button
        ],
      ),
    );
  }

  // ── Header: ikon + judul ─────────────────────────────────────────────────
  Widget _buildHeaderSection() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Buat Akun',
          style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          'Mulailah perjalanan hidup sehat bersama kami',
          style: AppTextStyles.appTagline.copyWith(
            color: Colors.white.withOpacity(0.65),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Form card putih — konsisten dengan login ─────────────────────────────
  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Nama ──
            _buildLabel('NAMA LENGKAP'),
            const SizedBox(height: 8),
            _NameTextField(controller: _nameController),

            const SizedBox(height: 18),

            // ── Email ──
            _buildLabel('ALAMAT EMAIL'),
            const SizedBox(height: 8),
            _EmailTextField(controller: _emailController),

            const SizedBox(height: 18),

            // ── Nomor HP ──
            _buildLabel('NOMOR HP'),
            const SizedBox(height: 8),
            _PhoneTextField(controller: _phoneController),

            const SizedBox(height: 18),

            // ── Password ──
            _buildLabel('BUAT KATA SANDI'),
            const SizedBox(height: 8),
            _PasswordTextField(controller: _passwordController),

            const SizedBox(height: 18),

            // ── Konfirmasi password ──
            _buildLabel('KONFIRMASI KATA SANDI'),
            const SizedBox(height: 8),
            _ConfirmPasswordTextField(
              controller: _confirmPasswordController,
              originalPasswordController: _passwordController,
            ),

            const SizedBox(height: 28),

            // ── Tombol daftar ──
            _buildDaftarButton(),

            const SizedBox(height: 24),

            // ── Link login ──
            _buildLoginRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.labelUppercase);
  }

  Widget _buildDaftarButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _prosesDaftar,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Daftar Sekarang', style: AppTextStyles.buttonPrimary),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Sudah punya akun? ', style: AppTextStyles.labelLink),
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Text('Masuk di sini', style: AppTextStyles.link),
        ),
      ],
    );
  }
}

// ── Arc painter — identik dengan login ──────────────────────────────────────
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1D5C2E).withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.55);
    path.quadraticBezierTo(size.width * 0.5, size.height, 0, size.height * 0.6);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Sub-widgets form ────────────────────────────────────────────────────────

class _NameTextField extends StatelessWidget {
  final TextEditingController controller;
  const _NameTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.name,
      style: AppTextStyles.inputText,
      decoration: _inputDecoration(
        hintText: 'John Doe',
        icon: Icons.person_outline_rounded,
      ),
    );
  }
}

class _EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: AppTextStyles.inputText,
      decoration: _inputDecoration(
        hintText: 'john@gmail.com',
        icon: Icons.email_outlined,
      ),
    );
  }
}

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
      error = null;
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
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.phone,
      style: AppTextStyles.inputText,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(13),
      ],
      onChanged: _validate,
      decoration: InputDecoration(
        hintText: '08xx xxxx xxxx',
        hintStyle: AppTextStyles.inputHint,
        prefixIcon: const Icon(
          Icons.phone_outlined,
          color: AppColors.textHint,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
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
            color: _errorText != null
                ? AppColors.error
                : AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        errorText: _errorText,
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
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

  void _checkStrength(String value) {
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
    if (value.contains(RegExp(r'[a-zA-Z]')) && value.contains(RegExp(r'[0-9]')))
      score += 0.34;

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
        TextField(
          controller: widget.controller,
          obscureText: _isObscured,
          onChanged: _checkStrength,
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
        if (_strengthText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _strengthScore,
                      backgroundColor: AppColors.inputBorder,
                      color: _strengthColor,
                      minHeight: 5,
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
                      fontSize: 11,
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

class _ConfirmPasswordTextFieldState extends State<_ConfirmPasswordTextField> {
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
        TextField(
          controller: widget.controller,
          obscureText: _isObscured,
          onChanged: _checkMatch,
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
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
        if (_matchText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
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

// ── Input decoration helper ──────────────────────────────────────────────────
InputDecoration _inputDecoration({
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
