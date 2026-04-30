import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';
import '../../../services/wallet_service.dart';

class IsiSaldoScreen extends StatefulWidget {
  const IsiSaldoScreen({super.key});
  @override
  State<IsiSaldoScreen> createState() => _IsiSaldoScreenState();
}

class _IsiSaldoScreenState extends State<IsiSaldoScreen>
    with TickerProviderStateMixin {
  final WalletService _walletService = WalletService();
  final user = FirebaseAuth.instance.currentUser;
  final _nominalController = TextEditingController();

  int? _selectedNominal;
  // Steps: 0=pilih nominal, 1=konfirmasi, 2=qris, 3=menunggu admin
  int _currentStep = 0;
  bool _isLoading = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectNominal(int nominal) {
    setState(() {
      _selectedNominal = nominal;
      _nominalController.text = nominal.toString();
    });
  }

  int get _nominal {
    if (_selectedNominal != null) return _selectedNominal!;
    return int.tryParse(_nominalController.text) ?? 0;
  }

  void _lanjutKonfirmasi() {
    if (_nominal < 10000) {
      _showSnackbar('Minimal isi saldo Rp 10.000', AppColors.warning);
      return;
    }
    setState(() => _currentStep = 1);
  }

  void _tampilkanQris() => setState(() => _currentStep = 2);

  Future<void> _sudahBayar() async {
    setState(() => _isLoading = true);

    // Kirim sebagai pending — admin yang akan approve
    final error = await _walletService.topUpSaldo(
      userId: user!.uid,
      amount: _nominal.toDouble(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        _showSnackbar(error, AppColors.error);
      } else {
        setState(() => _currentStep = 3);
      }
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  String _formatHarga(int h) => h.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0 || _currentStep == 3,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 0 && _currentStep < 3) {
          setState(() => _currentStep--);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildStepContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final titles = ['Isi Saldo', 'Konfirmasi', 'Pembayaran QRIS', 'Menunggu Konfirmasi'];
    return Padding(
      padding: EdgeInsets.fromLTRB(_currentStep == 3 ? 20 : 8, 16, 20, 0),
      child: Row(children: [
        if (_currentStep < 3)
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryGreen),
            onPressed: () {
              if (_currentStep == 0) { Navigator.pop(context); }
              else { setState(() => _currentStep--); }
            },
          ),
        Expanded(
          child: Text(titles[_currentStep],
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ),
      ]),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep0PilihNominal();
      case 1: return _buildStep1Konfirmasi();
      case 2: return _buildStep2Qris();
      case 3: return _buildStep3MenungguAdmin();
      default: return const SizedBox();
    }
  }

  // ═══════ STEP 0: PILIH NOMINAL ═══════
  Widget _buildStep0PilihNominal() {
    return Column(children: [
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildStepIndicator(0),
          const SizedBox(height: 20),
          Text('Pilih Nominal', style: AppTextStyles.h3),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.8,
            children: AppConstants.topUpNominals.map((nom) {
              final sel = _selectedNominal == nom;
              return GestureDetector(
                onTap: () => _selectNominal(nom),
                child: Container(
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primaryGreen : AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? AppColors.primaryGreen : AppColors.inputBorder,
                      width: sel ? 2 : 1),
                    boxShadow: sel ? [BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                      blurRadius: 8, offset: const Offset(0, 2))] : null,
                  ),
                  child: Center(child: Text('Rp ${_formatHarga(nom)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: sel ? AppColors.white : AppColors.textPrimary))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Atau Masukkan Nominal', style: AppTextStyles.labelUppercase),
          const SizedBox(height: 10),
          TextField(
            controller: _nominalController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _selectedNominal = null),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.h2,
            decoration: InputDecoration(
              prefixText: 'Rp  ',
              prefixStyle: AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
              hintText: '0', hintStyle: AppTextStyles.h2.copyWith(color: AppColors.textHint),
              filled: true, fillColor: AppColors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.inputBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.inputBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          const SizedBox(height: 8),
          Text('Minimal isi saldo Rp 10.000', style: AppTextStyles.caption),
        ]),
      )),
      _buildBottomButton('Lanjut ke Pembayaran', _lanjutKonfirmasi),
    ]);
  }

  // ═══════ STEP 1: KONFIRMASI ═══════
  Widget _buildStep1Konfirmasi() {
    return Column(children: [
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _buildStepIndicator(1),
          const SizedBox(height: 24),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.qr_code_2_rounded,
                    color: AppColors.primaryGreen, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Pembayaran via QRIS', style: AppTextStyles.h3),
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              _buildSummaryRow('Nominal Top-Up', 'Rp ${_formatHarga(_nominal)}'),
              const SizedBox(height: 10),
              _buildSummaryRow('Biaya Admin', 'Gratis'),
              const SizedBox(height: 10),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 10),
              _buildSummaryRow('Total Bayar', 'Rp ${_formatHarga(_nominal)}', isBold: true),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.2))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'Setelah scan QRIS, pembayaran akan diverifikasi oleh admin. Saldo akan bertambah setelah admin mengkonfirmasi.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.info))),
            ]),
          ),
        ]),
      )),
      _buildBottomButton('Lanjut ke QRIS', _tampilkanQris),
    ]);
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: isBold
          ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)
          : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      Text(value, style: isBold
          ? AppTextStyles.h3.copyWith(color: AppColors.primaryGreen)
          : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
    ]);
  }

  // ═══════ STEP 2: QRIS ═══════
  Widget _buildStep2Qris() {
    return Column(children: [
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _buildStepIndicator(2),
          const SizedBox(height: 24),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              Text('Scan QR untuk membayar', style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Container(
                width: 220, height: 220, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen, width: 3)),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Opacity(
                    opacity: 0.8 + (_pulseController.value * 0.2),
                    child: CustomPaint(
                      size: const Size(196, 196),
                      painter: _FakeQrisPainter()),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
                child: Text('Rp ${_formatHarga(_nominal)}',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen)),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.shield_rounded, color: AppColors.success, size: 16),
                ),
                const SizedBox(width: 8),
                Text('Pembayaran aman & terenkripsi',
                    style: AppTextStyles.caption.copyWith(color: AppColors.success)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          Text('Menunggu pembayaran...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
        ]),
      )),
      _buildBottomButton(
        _isLoading ? '' : 'Saya Sudah Bayar',
        _isLoading ? null : _sudahBayar,
        isLoading: _isLoading,
      ),
    ]);
  }

  // ═══════ STEP 3: MENUNGGU KONFIRMASI ADMIN ═══════
  Widget _buildStep3MenungguAdmin() {
    return Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.12), shape: BoxShape.circle),
          child: const Icon(Icons.schedule_rounded,
              color: AppColors.warning, size: 56),
        ),
        const SizedBox(height: 24),
        Text('Menunggu Konfirmasi Admin', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text(
          'Pembayaran Anda sedang diverifikasi oleh admin.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Nominal badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2))),
          child: Text('Rp ${_formatHarga(_nominal)}',
              style: AppTextStyles.h1.copyWith(color: AppColors.primaryGreen)),
        ),
        const SizedBox(height: 20),
        // Info card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.info.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
                const SizedBox(width: 8),
                Text('Informasi', style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.info)),
              ]),
              const SizedBox(height: 10),
              Text(
                '• Saldo akan otomatis bertambah setelah admin mengkonfirmasi pembayaran.\n'
                '• Proses verifikasi biasanya membutuhkan waktu beberapa menit.\n'
                '• Anda dapat memantau status di halaman Dompet Digital.',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, height: AppConstants.buttonHeight,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: Text('Kembali ke Dompet', style: AppTextStyles.buttonPrimary),
          ),
        ),
      ]),
    ));
  }

  // ═══════ SHARED WIDGETS ═══════
  Widget _buildStepIndicator(int step) {
    return Row(children: List.generate(3, (i) {
      final active = i <= step;
      return Expanded(child: Container(
        margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
        height: 4,
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGreen : AppColors.divider,
          borderRadius: BorderRadius.circular(2)),
      ));
    }));
  }

  Widget _buildBottomButton(String text, VoidCallback? onPressed,
      {bool isLoading = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, -4)),
      ]),
      child: SizedBox(
        width: double.infinity, height: AppConstants.buttonHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)), elevation: 0),
          child: isLoading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
              : Text(text, style: AppTextStyles.buttonPrimary),
        ),
      ),
    );
  }
}

// ═══════ FAKE QRIS PAINTER ═══════
class _FakeQrisPainter extends CustomPainter {
  final Random _rng = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1A1A1A);
    final cellSize = size.width / 25;

    _drawFinderPattern(canvas, paint, 0, 0, cellSize);
    _drawFinderPattern(canvas, paint, size.width - 7 * cellSize, 0, cellSize);
    _drawFinderPattern(canvas, paint, 0, size.height - 7 * cellSize, cellSize);

    for (int row = 0; row < 25; row++) {
      for (int col = 0; col < 25; col++) {
        if ((row < 8 && col < 8) || (row < 8 && col > 16) || (row > 16 && col < 8)) continue;
        if (_rng.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize), paint);
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Paint paint, double x, double y, double cell) {
    canvas.drawRect(Rect.fromLTWH(x, y, 7 * cell, 7 * cell), paint);
    final white = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + cell, y + cell, 5 * cell, 5 * cell), white);
    canvas.drawRect(Rect.fromLTWH(x + 2 * cell, y + 2 * cell, 3 * cell, 3 * cell), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
