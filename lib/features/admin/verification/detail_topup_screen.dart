import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/core/constants.dart';
import 'package:sayurku_kelompok6/services/wallet_service.dart';

class DetailVerifikasiTopupScreen extends StatefulWidget {
  final String txId;
  final String userId;
  final String docPath; // Path lengkap: wallets/{userId}/transactions/{txId}

  const DetailVerifikasiTopupScreen({
    Key? key,
    required this.txId,
    required this.userId,
    required this.docPath,
  }) : super(key: key);

  @override
  State<DetailVerifikasiTopupScreen> createState() =>
      _DetailVerifikasiTopupScreenState();
}

class _DetailVerifikasiTopupScreenState
    extends State<DetailVerifikasiTopupScreen> {
  final WalletService _walletService = WalletService();
  bool _isLoading = false;

  // ── Data dikunci di initState agar tidak reload saat tombol ditekan ──
  Future<Map<String, dynamic>?>? _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchDetail();
  }

  Future<Map<String, dynamic>?> _fetchDetail() async {
    try {
      final txDoc = await FirebaseFirestore.instance.doc(widget.docPath).get();
      final userDoc = await FirebaseFirestore.instance
          .collection(AppConstants.colUsers)
          .doc(widget.userId)
          .get();

      if (!txDoc.exists) return null;

      final txData = txDoc.data() as Map<String, dynamic>;
      final userData = userDoc.exists
          ? userDoc.data() as Map<String, dynamic>
          : {};

      return {
        ...txData,
        'id': txDoc.id,
        'namaUser': userData['namaLengkap'] ?? 'Customer',
        'emailUser': userData['email'] ?? '-',
        'nomorHp': userData['nomorHp'] ?? '-',
      };
    } catch (e) {
      return null;
    }
  }

  // ── Format tanggal ────────────────────────────────────────────
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    final date = timestamp.toDate();
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} WIB';
  }

  // ── Format Rupiah ─────────────────────────────────────────────
  String _formatRupiah(double nominal) {
    return 'Rp ${nominal.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  // ── Approve top-up & tambah saldo user ───────────────────────
  Future<void> _approveTopUp(double amount) async {
    setState(() => _isLoading = true);

    final error = await _walletService.approveTopUp(
      userId: widget.userId,
      transactionId: widget.txId,
      amount: amount,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Saldo berhasil ditambahkan!'),
        backgroundColor: error != null ? AppColors.error : AppColors.success,
      ),
    );

    if (error == null) Navigator.pop(context);
  }

  // ── Reject top-up ─────────────────────────────────────────────
  Future<void> _rejectTopUp() async {
    setState(() => _isLoading = true);

    final error = await _walletService.rejectTopUp(
      userId: widget.userId,
      transactionId: widget.txId,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Permintaan top-up ditolak.'),
        backgroundColor: error != null ? AppColors.error : AppColors.warning,
      ),
    );

    if (error == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Top-Up',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Data transaksi tidak ditemukan.'));
          }

          final data = snapshot.data!;
          final namaUser = data['namaUser'] ?? 'Customer';
          final emailUser = data['emailUser'] ?? '-';
          final nomorHp = data['nomorHp'] ?? '-';
          final amount = (data['amount'] ?? 0).toDouble();
          final status = (data['status'] ?? AppConstants.txStatusPending)
              .toString();
          final timestamp = data['timestamp'] as Timestamp?;
          final imageUrl = data['buktiTransfer'] as String?;
          final txId = data['id'] ?? widget.txId;
          final isPending = status == AppConstants.txStatusPending;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── KARTU USER INFO (sama seperti detail_pesanan) ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.inputBackground,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.textHint,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(namaUser, style: AppTextStyles.h3),
                            const SizedBox(height: 2),
                            Text(
                              '#${txId.length > 8 ? txId.substring(0, 8) : txId}',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 2),
                            Text(emailUser, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── BUKTI TRANSFER (VERSI BASE64) ──────────────────
                Text('BUKTI TRANSFER', style: AppTextStyles.labelUppercase),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // 1. Tampilkan gambar JIKA sandinya ada
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Builder(
                            builder: (context) {
                              try {
                                return Image.memory(
                                  base64Decode(imageUrl),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              } catch (e) {
                                return const Center(
                                  child: Text(
                                    'Gagal membuka sandi gambar!',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                      // 2. Tampilkan Ikon JIKA sandinya kosong
                      if (imageUrl == null || imageUrl.isEmpty)
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: Colors.white54,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada foto bukti transfer',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),

                      // 3. Tombol Perbesar Gambar
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => _showFullImage(context, imageUrl),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                  0.6,
                                ), // Dipergelap agar lebih kontras
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white38),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.zoom_in,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Perbesar Gambar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── RINCIAN NOMINAL (sama seperti rincian belanja) ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Rincian\nTop-Up', style: AppTextStyles.h2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _bgStatus(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _labelStatus(status).toUpperCase(),
                              style: AppTextStyles.caption.copyWith(
                                color: _colorStatus(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _rowInfo('Jenis Transaksi', 'Isi Saldo (Top-Up)'),
                      const Divider(height: 20, color: AppColors.divider),
                      _rowInfo('Waktu Pengajuan', _formatDate(timestamp)),
                      const Divider(height: 20, color: AppColors.divider),
                      _rowInfo('No. HP', nomorHp),
                      const Divider(height: 20, color: AppColors.divider),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nominal Pengisian',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatRupiah(amount),
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── INFO BANNER ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pastikan nama pengirim di struk sesuai dengan nama akun '
                          'pengguna untuk menghindari kesalahan saldo.',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF2E7D32),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),

      // ─── BOTTOM ACTION BUTTONS (persis seperti detail_pesanan) ──
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }

          final data = snapshot.data!;
          final amount = (data['amount'] ?? 0).toDouble();
          final status = (data['status'] ?? AppConstants.txStatusPending)
              .toString();
          final isPending = status == AppConstants.txStatusPending;

          if (!isPending) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // ─ Tolak
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => _konfirmasiTolak(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Tolak',
                      style: AppTextStyles.buttonPrimary.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // ─ Terima & Isi Saldo
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _konfirmasiApprove(amount),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.check_circle,
                            color: AppColors.white,
                            size: 20,
                          ),
                    label: Text(
                      _isLoading ? 'Memproses...' : 'Terima & Isi Saldo',
                      style: AppTextStyles.buttonPrimary,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Konfirmasi dialog sebelum approve ─────────────────────────
  void _konfirmasiApprove(double amount) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Persetujuan'),
        content: Text('Tambahkan ${_formatRupiah(amount)} ke saldo customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveTopUp(amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text(
              'Ya, ACC Saldo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Konfirmasi dialog sebelum reject ─────────────────────────
  void _konfirmasiTolak() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Penolakan'),
        content: const Text('Tolak permintaan top-up ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectTopUp();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Ya, Tolak',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Full image viewer (VERSI BASE64) ──────────────────────────
  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.memory(
                base64Decode(imageUrl),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Row info helper ───────────────────────────────────────────
  Widget _rowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 14)),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ── Status helpers ────────────────────────────────────────────
  String _labelStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color _colorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _bgStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning.withOpacity(0.12);
      case 'approved':
        return AppColors.success.withOpacity(0.12);
      case 'rejected':
        return AppColors.error.withOpacity(0.12);
      default:
        return AppColors.inputBackground;
    }
  }
}
