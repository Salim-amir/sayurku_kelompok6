import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';
import '../../../services/wallet_service.dart';

class IsiSaldoScreen extends StatefulWidget {
  const IsiSaldoScreen({super.key});

  @override
  State<IsiSaldoScreen> createState() => _IsiSaldoScreenState();
}

class _IsiSaldoScreenState extends State<IsiSaldoScreen> {
  final WalletService _walletService = WalletService();
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nominalController = TextEditingController();

  int? _selectedNominal;
  bool _isLoading = false;

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  void _selectNominal(int nominal) {
    setState(() {
      _selectedNominal = nominal;
      _nominalController.text = nominal.toString();
    });
  }

  void _onCustomNominalChanged(String value) {
    setState(() {
      _selectedNominal = null;
    });
  }

  int get _nominal {
    if (_selectedNominal != null) return _selectedNominal!;
    return int.tryParse(_nominalController.text) ?? 0;
  }

  Future<void> _ajukanTopUp() async {
    if (_nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan nominal yang valid',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_nominal < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimal isi saldo Rp 10.000',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await _walletService.topUpSaldo(
      userId: user!.uid,
      amount: _nominal.toDouble(),
    );

    setState(() => _isLoading = false);

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error,
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Permintaan Terkirim!', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Permintaan isi saldo sebesar Rp ${_formatHarga(_nominal)} sedang menunggu konfirmasi admin.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // tutup dialog
                  Navigator.pop(context); // kembali ke dompet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Kembali ke Dompet',
                    style: AppTextStyles.buttonPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNominalCepat(),
                    const SizedBox(height: 24),
                    _buildCustomNominal(),
                    const SizedBox(height: 24),
                    _buildInstruksi(),
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
          Text('Isi Saldo',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  // ── NOMINAL CEPAT ──────────────────────────────────
  Widget _buildNominalCepat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilih Nominal', style: AppTextStyles.h3),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.8,
          children: AppConstants.topUpNominals.map((nominal) {
            final isSelected = _selectedNominal == nominal;
            return GestureDetector(
              onTap: () => _selectNominal(nominal),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primaryGreen : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.inputBorder,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Rp ${_formatHarga(nominal)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          isSelected ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── CUSTOM NOMINAL ─────────────────────────────────
  Widget _buildCustomNominal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Atau Masukkan Nominal',
            style: AppTextStyles.labelUppercase),
        const SizedBox(height: 10),
        TextField(
          controller: _nominalController,
          keyboardType: TextInputType.number,
          onChanged: _onCustomNominalChanged,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.h2,
          decoration: InputDecoration(
            prefixText: 'Rp  ',
            prefixStyle:
                AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
            hintText: '0',
            hintStyle: AppTextStyles.h2.copyWith(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
        const SizedBox(height: 8),
        Text('Minimal isi saldo Rp 10.000',
            style: AppTextStyles.caption),
      ],
    );
  }

  // ── INSTRUKSI ──────────────────────────────────────
  Widget _buildInstruksi() {
    return Container(
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
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Text('Cara Isi Saldo',
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700, color: AppColors.info)),
            ],
          ),
          const SizedBox(height: 10),
          _buildInstruksiStep('1', 'Pilih atau masukkan nominal'),
          _buildInstruksiStep('2', 'Tekan tombol "Ajukan Isi Saldo"'),
          _buildInstruksiStep('3', 'Transfer ke rekening admin'),
          _buildInstruksiStep('4', 'Admin akan memverifikasi pembayaran'),
          _buildInstruksiStep('5', 'Saldo otomatis bertambah'),
        ],
      ),
    );
  }

  Widget _buildInstruksiStep(String no, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(no,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.info)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ─────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_nominal > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Isi Saldo',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                  Text(
                    'Rp ${_formatHarga(_nominal)}',
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: AppConstants.buttonHeight,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _ajukanTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                disabledBackgroundColor:
                    AppColors.primaryGreen.withOpacity(0.5),
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
                  : Text('Ajukan Isi Saldo',
                      style: AppTextStyles.buttonPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
