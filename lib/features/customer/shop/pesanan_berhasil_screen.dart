import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';

class PesananBerhasilScreen extends StatefulWidget {
  final String metodePembayaran;
  final double totalBayar;

  const PesananBerhasilScreen({
    super.key,
    required this.metodePembayaran,
    required this.totalBayar,
  });

  @override
  State<PesananBerhasilScreen> createState() => _PesananBerhasilScreenState();
}

class _PesananBerhasilScreenState extends State<PesananBerhasilScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final isDompet = widget.metodePembayaran == 'Dompet Digital';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Animated check icon ──
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Title ──
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      Text(
                        'Pesanan Berhasil!',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isDompet
                            ? 'Saldo dompet Anda telah dipotong.\nPesanan sedang menunggu diproses.'
                            : 'Pesanan Anda sedang menunggu\nkonfirmasi dari admin.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Order summary card ──
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.payment_rounded,
                          'Metode Pembayaran',
                          widget.metodePembayaran,
                        ),
                        const Divider(height: 24, color: AppColors.divider),
                        _buildInfoRow(
                          Icons.receipt_rounded,
                          'Total Pembayaran',
                          'Rp ${_formatHarga(widget.totalBayar.toInt())}',
                          valueColor: AppColors.primaryGreen,
                          valueBold: true,
                        ),
                        const Divider(height: 24, color: AppColors.divider),
                        _buildInfoRow(
                          Icons.schedule_rounded,
                          'Status',
                          'Menunggu Konfirmasi',
                          valueColor: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Buttons ──
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.home_rounded,
                              color: AppColors.white, size: 20),
                          label: Text('Kembali ke Beranda',
                              style: AppTextStyles.buttonPrimary),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
