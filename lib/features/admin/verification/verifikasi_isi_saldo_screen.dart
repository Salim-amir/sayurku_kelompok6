import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/core/constants.dart';
import 'package:sayurku_kelompok6/services/wallet_service.dart';
import 'detail_topup_screen.dart';

class VerifikasiIsiSaldoPage extends StatefulWidget {
  const VerifikasiIsiSaldoPage({Key? key}) : super(key: key);

  @override
  State<VerifikasiIsiSaldoPage> createState() => _VerifikasiIsiSaldoPageState();
}

class _VerifikasiIsiSaldoPageState extends State<VerifikasiIsiSaldoPage> {
  final WalletService _walletService = WalletService();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Filter: 'semua' = semua status, selain itu filter spesifik ──
  // Default 'pending' agar admin langsung lihat yang perlu diverifikasi
  String _selectedFilter = AppConstants.txStatusPending;

  late Stream<List<Map<String, dynamic>>> _topUpStream;

  @override
  void initState() {
    super.initState();
    // collectionGroup — reactive instan saat approve/reject
    _topUpStream = _walletService.getSemuaTopUpAdmin();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatRupiah(double nominal) {
    return 'Rp ${nominal.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _topUpStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        final allTopUp = snapshot.data ?? [];

        // ── Filter di sisi client ──────────────────────────────────────────
        // 'semua'  → tampilkan semua status (pending + approved + rejected)
        // lainnya  → filter berdasarkan status spesifik
        final List<Map<String, dynamic>> filtered = _selectedFilter == 'semua'
            ? allTopUp
            : allTopUp.where((tx) {
                final s = (tx['status'] ?? '').toString().toLowerCase();
                return s == _selectedFilter.toLowerCase();
              }).toList();

        return CustomScrollView(
          slivers: [
            // ─── DASHBOARD CARD — REAKTIF dari filtered.length ───────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDashboardCard(filtered.length),
              ),
            ),

            // ─── SEARCH BAR ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari Berdasarkan Nama...',
                    hintStyle: AppTextStyles.inputHint,
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textHint, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: AppColors.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  style: AppTextStyles.inputText,
                ),
              ),
            ),

            // ─── JUDUL + FILTER POPUP ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (_selectedFilter == AppConstants.txStatusApproved ||
                                  _selectedFilter ==
                                      AppConstants.txStatusRejected)
                              ? 'Riwayat Top-Up'
                              : _selectedFilter == 'semua'
                                  ? 'Semua Transaksi'
                                  : 'Permintaan Terbaru',
                          style: AppTextStyles.h3,
                        ),
                        // Tampilkan label filter aktif (kecuali pending yang jadi default)
                        if (_selectedFilter != AppConstants.txStatusPending)
                          Text(
                            'Filter: ${_labelStatus(_selectedFilter)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.tune,
                        // Ikon hijau jika filter bukan default
                        color: _selectedFilter == AppConstants.txStatusPending
                            ? AppColors.textPrimary
                            : AppColors.primaryGreen,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (v) =>
                          setState(() => _selectedFilter = v),
                      itemBuilder: (_) => [
                        // ─ 4 pilihan yang jelas, tanpa duplikat ──────────
                        PopupMenuItem(
                          value: AppConstants.txStatusPending,
                          child: Row(
                            children: [
                              Icon(Icons.pending_outlined,
                                  size: 18,
                                  color: _selectedFilter ==
                                          AppConstants.txStatusPending
                                      ? AppColors.primaryGreen
                                      : AppColors.textPrimary),
                              const SizedBox(width: 8),
                              const Text('Menunggu Konfirmasi'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: AppConstants.txStatusApproved,
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 18,
                                  color: _selectedFilter ==
                                          AppConstants.txStatusApproved
                                      ? AppColors.primaryGreen
                                      : AppColors.textPrimary),
                              const SizedBox(width: 8),
                              const Text('Sudah Disetujui'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: AppConstants.txStatusRejected,
                          child: Row(
                            children: [
                              Icon(Icons.cancel_outlined,
                                  size: 18,
                                  color: _selectedFilter ==
                                          AppConstants.txStatusRejected
                                      ? AppColors.primaryGreen
                                      : AppColors.textPrimary),
                              const SizedBox(width: 8),
                              const Text('Ditolak'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'semua',
                          child: Row(
                            children: [
                              Icon(Icons.list_alt_outlined,
                                  size: 18, color: AppColors.textPrimary),
                              SizedBox(width: 8),
                              Text('Tampilkan Semua'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── LIST TOP-UP ─────────────────────────────────────────────
            filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 56,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada permintaan top-up.',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tx = filtered[index];
                          final userId = tx['userId'] ?? '';

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection(AppConstants.colUsers)
                                .doc(userId)
                                .get(),
                            builder: (context, userSnap) {
                              String namaUser = 'Memuat...';
                              String fotoUrl = '';
                              if (userSnap.hasData &&
                                  userSnap.data!.exists) {
                                final ud = userSnap.data!.data()
                                    as Map<String, dynamic>;
                                namaUser =
                                    ud['namaLengkap'] ?? 'Customer';
                                fotoUrl = ud['fotoUrl'] ?? ud['photoUrl'] ?? '';
                              }

                              if (_searchQuery.isNotEmpty &&
                                  !namaUser
                                      .toLowerCase()
                                      .contains(_searchQuery)) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildTopUpCard(
                                    tx: tx, namaUser: namaUser, fotoUrl: fotoUrl),
                              );
                            },
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      },
    );
  }

  // ─── DASHBOARD CARD ──────────────────────────────────────────────────────
  Widget _buildDashboardCard(int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 140,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DASHBOARD ADMIN',
                    style: AppTextStyles.labelUppercase.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$total Top-Up',
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verifikasi bukti transfer customer dengan teliti!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TOP-UP CARD ─────────────────────────────────────────────────────────
  Widget _buildTopUpCard({
    required Map<String, dynamic> tx,
    required String namaUser,
    required String fotoUrl,
  }) {
    final amount = (tx['amount'] ?? 0).toDouble();
    final timestamp = tx['timestamp'] as Timestamp?;
    final status = (tx['status'] ?? AppConstants.txStatusPending).toString();
    final txId = tx['id'] ?? '';
    final userId = tx['userId'] ?? '';
    final docPath = tx['docPath'] ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailVerifikasiTopupScreen(
            txId: txId,
            userId: userId,
            docPath: docPath,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  backgroundImage: fotoUrl.isNotEmpty
                      ? (fotoUrl.startsWith('http')
                          ? NetworkImage(fotoUrl) as ImageProvider
                          : MemoryImage(base64Decode(fotoUrl)))
                      : null,
                  child: fotoUrl.isEmpty
                      ? Text(
                          namaUser.isNotEmpty ? namaUser[0].toUpperCase() : '?',
                          style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(namaUser, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        '#${txId.length > 8 ? txId.substring(0, 8) : txId} • ${_getTimeAgo(timestamp)}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _colorStatus(status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _labelStatus(status).toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: _colorStatus(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.divider),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nominal Top-Up', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(amount),
                      style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen, fontSize: 16),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: AppColors.textHint),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  String _labelStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'semua':
        return 'Semua';
      default:
        return status;
    }
  }

  Color _colorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFC41E3A);
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}