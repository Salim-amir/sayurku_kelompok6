import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';
import '../../../services/wallet_service.dart';
import 'isi_saldo_screen.dart';

class DompetDigitalScreen extends StatefulWidget {
  const DompetDigitalScreen({super.key});

  @override
  State<DompetDigitalScreen> createState() => _DompetDigitalScreenState();
}

class _DompetDigitalScreenState extends State<DompetDigitalScreen> {
  final WalletService _walletService = WalletService();
  final user = FirebaseAuth.instance.currentUser;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSaldoCard(),
                    const SizedBox(height: 24),
                    _buildRiwayatSection(),
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
          Text('Dompet Digital',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  // ── SALDO CARD ─────────────────────────────────────
  Widget _buildSaldoCard() {
    if (user == null) return const SizedBox();

    return StreamBuilder<double>(
      stream: _walletService.getSaldo(user!.uid),
      builder: (context, snapshot) {
        final saldo = snapshot.data ?? 0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D5C2E), Color(0xFF2D7A3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text('Saldo Anda',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Rp ${_formatHarga(saldo.toInt())}',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.white,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 20),
              // Tombol Isi Saldo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const IsiSaldoScreen()),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      size: 20),
                  label: Text('Isi Saldo',
                      style: AppTextStyles.buttonPrimary
                          .copyWith(color: AppColors.primaryGreen)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── RIWAYAT TRANSAKSI ──────────────────────────────
  Widget _buildRiwayatSection() {
    if (user == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riwayat Transaksi', style: AppTextStyles.h3),
        const SizedBox(height: 14),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _walletService.getRiwayatTransaksi(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                    color: AppColors.primaryGreen),
              ));
            }

            final transaksiList = snapshot.data ?? [];

            if (transaksiList.isEmpty) {
              return _buildEmptyRiwayat();
            }

            return Column(
              children: transaksiList
                  .map((tx) => _buildTransaksiItem(tx))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyRiwayat() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded,
              color: AppColors.textHint.withOpacity(0.4), size: 48),
          const SizedBox(height: 12),
          Text('Belum Ada Transaksi',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildTransaksiItem(Map<String, dynamic> tx) {
    final isTopUp = tx['type'] == AppConstants.txTopUp;
    final amount = (tx['amount'] ?? 0).toDouble();
    final status = tx['status'] ?? '';
    final keterangan = tx['keterangan'] ?? '';
    final timestamp = tx['timestamp']?.toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isTopUp
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.error.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTopUp
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isTopUp ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTopUp ? 'Isi Saldo' : 'Pembayaran',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  keterangan,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textHint),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatTanggalWaktu(timestamp),
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
          // Amount + Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isTopUp ? '+' : '-'}Rp ${_formatHarga(amount.toInt())}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isTopUp ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              _buildTxStatusBadge(status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTxStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case AppConstants.txStatusPending:
        bgColor = AppColors.warning.withOpacity(0.12);
        textColor = AppColors.warning;
        label = 'Pending';
        break;
      case AppConstants.txStatusApproved:
        bgColor = AppColors.success.withOpacity(0.12);
        textColor = AppColors.success;
        label = 'Berhasil';
        break;
      case AppConstants.txStatusSuccess:
        bgColor = AppColors.success.withOpacity(0.12);
        textColor = AppColors.success;
        label = 'Sukses';
        break;
      case AppConstants.txStatusRejected:
        bgColor = AppColors.error.withOpacity(0.12);
        textColor = AppColors.error;
        label = 'Ditolak';
        break;
      default:
        bgColor = AppColors.textHint.withOpacity(0.12);
        textColor = AppColors.textHint;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }

  String _formatTanggalWaktu(DateTime date) {
    final bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${bulan[date.month]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
