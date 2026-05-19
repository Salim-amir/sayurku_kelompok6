import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import '../customer/shop/home_screen.dart';
import '../admin/dashboard/dashboard_admin_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _navigasiByRole(String role) {
    if (role == AppConstants.roleAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _prosesLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email dan kata sandi harus diisi!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final LoginResult result = await AuthService().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Berhasil Masuk!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      _navigasiByRole(result.role!);
    }
  }

  Future<void> _prosesLoginGoogle() async {
    setState(() => _isLoading = true);

    final String? error = await AuthService().loginWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Berhasil masuk dengan Google!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D2B1A),
      body: Stack(
        children: [
          // ── Decorative background blobs ──
          _buildBackground(size),

          // ── Main content ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  children: [
                    // ── Top brand section ──
                    _buildTopSection(),

                    // ── Login card ──
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: _buildLoginCard(),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Decorative blobs ────────────────────────────────────────────────────────
  Widget _buildBackground(Size size) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Top-right blob
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
          // Mid-left blob
          Positioned(
            top: size.height * 0.25,
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
          // Bottom blob
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
          // Leaf-like decorative arc top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width, 220),
              painter: _ArcPainter(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top brand ───────────────────────────────────────────────────────────────
  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 32),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // Logo container
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.5),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppConstants.appName,
              style: AppTextStyles.appName.copyWith(
                color: Colors.white,
                fontSize: 30,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppConstants.appTagline,
              style: AppTextStyles.appTagline.copyWith(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Login card ──────────────────────────────────────────────────────────────
  Widget _buildLoginCard() {
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
            // Heading
            Text(
              'Selamat Datang',
              style: AppTextStyles.h1.copyWith(
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Masuk untuk mulai belanja bahan segar',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 28),

            // Email field
            _buildLabel('ALAMAT EMAIL'),
            const SizedBox(height: 8),
            AppTextField(
              controller: _emailController,
              hintText: 'nama@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
            ),

            const SizedBox(height: 18),

            // Password field
            _buildLabel('KATA SANDI'),
            const SizedBox(height: 8),
            AppPasswordField(
              controller: _passwordController,
              hintText: '••••••••••',
              trailingAction: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                child: Text(
                  'Lupa Sandi?',
                  style: AppTextStyles.linkUppercase.copyWith(fontSize: 10),
                ),
              ),
              textInputAction: TextInputAction.done,
              onEditingComplete: _prosesLogin,
            ),

            const SizedBox(height: 28),

            // Login button
            _buildLoginButton(),

            const SizedBox(height: 20),

            // Divider
            _buildDivider(),

            const SizedBox(height: 20),

            // Google button
            _buildGoogleButton(),

            const SizedBox(height: 24),

            // Register row
            _buildRegisterRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.labelUppercase);
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _prosesLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.primaryGreen.withOpacity(0.4),
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
                  Text('Masuk', style: AppTextStyles.buttonPrimary),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('ATAU', style: AppTextStyles.dividerLabel),
        ),
        Expanded(child: Container(height: 1, color: AppColors.divider)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeightSM,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _prosesLoginGoogle,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" logo menggunakan CustomPaint
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(painter: _GoogleLogoPainter()),
            ),
            const SizedBox(width: 10),
            Text(
              'Lanjutkan dengan Google',
              style: AppTextStyles.buttonSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Belum punya akun? ', style: AppTextStyles.labelLink),
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: Text('Daftar Sekarang', style: AppTextStyles.link),
        ),
      ],
    );
  }
}

// ── Decorative arc painter ───────────────────────────────────────────────────
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

// ── Google "G" logo painter ─────────────────────────────────────────────────
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Warna segmen Google
    const colors = [
      Color(0xFF4285F4), // biru – kanan atas
      Color(0xFF34A853), // hijau – kanan bawah
      Color(0xFFFBBC05), // kuning – kiri bawah
      Color(0xFFEA4335), // merah – kiri atas
    ];

    final sweeps = [math.pi * 0.5, math.pi * 0.5, math.pi * 0.5, math.pi * 0.5];
    double startAngle = -math.pi / 4;

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72),
        startAngle + 0.08,
        sweeps[i] - 0.16,
        false,
        paint,
      );
      startAngle += sweeps[i];
    }

    // "G" horizontal bar (biru)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.72, cy), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
