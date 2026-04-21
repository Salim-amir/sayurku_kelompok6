import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';

class KonfirmasiPembayaranScreen extends StatelessWidget {
  final Map<String, dynamic> pesanan;

  const KonfirmasiPembayaranScreen({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    final totalHarga = (pesanan['totalHarga'] ?? 0).toDouble();
    final ongkosKirim = (pesanan['ongkosKirim'] ?? 0).toDouble();
    final totalBayar = totalHarga + ongkosKirim;
    final status = pesanan['status'] ?? AppConstants.statusMenunggu;
    final metodePembayaran = pesanan['metodePembayaran'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(status),
                    const SizedBox(height: 16),
                    _buildDetailPembayaran(
                        totalHarga, ongkosKirim, totalBayar),
                    const SizedBox(height: 16),
                    if (metodePembayaran == AppConstants.metodeTransfer)
                      _buildInfoRekening(),
                    const SizedBox(height: 16),
                    _buildInstruksi(metodePembayaran),
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
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primaryGreen),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Konfirmasi Pembayaran',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  // ── STATUS CARD ─────────────────────────────────────
  Widget _buildStatusCard(String status) {
    IconData icon;
    Color color;
    String message;

    switch (status) {
      case AppConstants.statusMenunggu:
        icon = Icons.hourglass_top_rounded;
        color = AppColors.warning;
        message = 'Menunggu konfirmasi pembayaran dari admin';
        break;
      case AppConstants.statusDiproses:
        icon = Icons.check_circle_rounded;
        color = AppColors.success;
        message = 'Pembayaran telah diverifikasi! Pesanan sedang diproses.';
        break;
      default:
        icon = Icons.info_rounded;
        color = AppColors.info;
        message = 'Status: $status';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            status,
            style: AppTextStyles.h3.copyWith(color: color),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── DETAIL PEMBAYARAN ──────────────────────────────
  Widget _buildDetailPembayaran(
      double totalHarga, double ongkosKirim, double totalBayar) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_rounded,
                  color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text('Detail Pembayaran', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 14),
          _buildBiayaRow('Subtotal Produk', totalHarga.toInt()),
          const SizedBox(height: 8),
          _buildBiayaRow('Ongkos Kirim', ongkosKirim.toInt()),
          const Divider(height: 24, color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pembayaran',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700)),
              Text(
                'Rp ${_formatHarga(totalBayar.toInt())}',
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.primaryGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiayaRow(String label, int harga) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        Text('Rp ${_formatHarga(harga)}', style: AppTextStyles.bodyMedium),
      ],
    );
  }

  // ── INFO REKENING ──────────────────────────────────
  Widget _buildInfoRekening() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_rounded,
                  color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text('Transfer ke Rekening', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow('Bank', 'BRI'),
          const SizedBox(height: 8),
          _buildInfoRow('No. Rekening', '0123-4567-8901-2345'),
          const SizedBox(height: 8),
          _buildInfoRow('Atas Nama', 'SayurKu Official'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── INSTRUKSI ──────────────────────────────────────
  Widget _buildInstruksi(String metode) {
    final isTransfer = metode == AppConstants.metodeTransfer;

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
              Text('Instruksi',
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700, color: AppColors.info)),
            ],
          ),
          const SizedBox(height: 10),
          if (isTransfer) ...[
            _buildStep('1', 'Transfer sesuai total pembayaran'),
            _buildStep('2', 'Admin akan memeriksa pembayaran Anda'),
            _buildStep(
                '3', 'Pesanan akan diproses setelah pembayaran terkonfirmasi'),
          ] else ...[
            _buildStep('1', 'Siapkan uang tunai sesuai total pembayaran'),
            _buildStep('2', 'Bayar saat pesanan diantarkan ke alamat Anda'),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(String no, String text) {
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
                  style: const TextStyle(
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

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
