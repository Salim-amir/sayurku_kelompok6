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
  String _selectedFilter = 'Semua';

  // ── Stream semua top-up, dikunci di initState ────────────────
  // Ambil SEMUA status sekaligus — filter dilakukan di client
  // agar dashboard card bisa reaktif tanpa ganti stream
  late Stream<List<Map<String, dynamic>>> _topUpStream;

  @override
  void initState() {
    super.initState();
    // null = ambil semua status (pending + approved + rejected)
    _topUpStream = _walletService.getSemuaTopUpAdmin();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Format Rupiah ─────────────────────────────────────────────
  String _formatRupiah(double nominal) {
    return 'Rp ${nominal.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }

  // ── Waktu relatif ─────────────────────────────────────────────
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

        // ── Filter status di sisi client ─────────────────────────
        final List<Map<String, dynamic>> filtered;
        if (_selectedFilter == 'Semua') {
          // Default: hanya pending
          filtered = allTopUp
              .where((tx) =>
                  (tx['status'] ?? '').toString().toLowerCase() ==
                  AppConstants.txStatusPending)
              .toList();
        } else {
          // Filter spesifik — approved / rejected juga tampil untuk riwayat
          filtered = allTopUp
              .where((tx) =>
                  (tx['status'] ?? '').toString().toLowerCase() ==
                  _selectedFilter.toLowerCase())
              .toList();
        }

        return CustomScrollView(
          slivers: [
            // ─── DASHBOARD CARD — angka REAKTIF dari filtered.length ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildDashboardCard(filtered.length),
              ),
            ),

            // ─── SEARCH BAR ──────────────────────────────────────
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
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.inputBorder),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  style: AppTextStyles.inputText,
                ),
              ),
            ),

            // ─── JUDUL + FILTER POPUP ─────────────────────────────
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
                              : 'Permintaan Terbaru',
                          style: AppTextStyles.h3,
                        ),
                        if (_selectedFilter != 'Semua')
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
                        color: _selectedFilter == 'Semua'
                            ? AppColors.textPrimary
                            : AppColors.primaryGreen,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (v) =>
                          setState(() => _selectedFilter = v),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'Semua',
                            child: Text('Tampilkan Semua (Pending)')),
                        PopupMenuItem(
                            value: AppConstants.txStatusPending,
                            child: const Text('Menunggu Konfirmasi')),
                        PopupMenuItem(
                            value: AppConstants.txStatusApproved,
                            child: const Text('Riwayat: Disetujui')),
                        PopupMenuItem(
                            value: AppConstants.txStatusRejected,
                            child: const Text('Riwayat: Ditolak')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── LIST TOP-UP ──────────────────────────────────────
            filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined,
                                size: 56, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada permintaan top-up.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary),
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
                              if (userSnap.hasData &&
                                  userSnap.data!.exists) {
                                final ud = userSnap.data!.data()
                                    as Map<String, dynamic>;
                                namaUser =
                                    ud['namaLengkap'] ?? 'Customer';
                              }

                              // Sembunyikan jika tidak cocok search
                              if (_searchQuery.isNotEmpty &&
                                  !namaUser
                                      .toLowerCase()
                                      .contains(_searchQuery)) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 16),
                                child: _buildTopUpCard(
                                    tx: tx, namaUser: namaUser),
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

  // ─── DASHBOARD CARD ──────────────────────────────────────────
  Widget _buildDashboardCard(int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DASHBOARD ADMIN',
            style: AppTextStyles.labelUppercase.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Permintaan: $total Top-Up',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet,
                  color: AppColors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Verifikasi pembayaran customer dengan teliti!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── TOP-UP CARD ─────────────────────────────────────────────
  Widget _buildTopUpCard({
    required Map<String, dynamic> tx,
    required String namaUser,
  }) {
    final amount = (tx['amount'] ?? 0).toDouble();
    final timestamp = tx['timestamp'] as Timestamp?;
    final status = (tx['status'] ?? AppConstants.txStatusPending).toString();
    final txId = tx['id'] ?? '';
    final userId = tx['userId'] ?? '';
    final docPath = tx['docPath'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.inputBackground,
                child: const Icon(Icons.person,
                    color: AppColors.textHint, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(namaUser, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '#${txId.length > 8 ? txId.substring(0, 8) : txId}',
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('• ${_getTimeAgo(timestamp)}',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorStatus(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _labelStatus(status).toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: _colorStatus(status),
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NOMINAL TOP-UP', style: AppTextStyles.labelUppercase),
              const SizedBox(height: 4),
              Text(
                _formatRupiah(amount),
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.primaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailVerifikasiTopupScreen(
                    txId: txId,
                    userId: userId,
                    docPath: docPath,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text('Detail',
                  style:
                      AppTextStyles.buttonPrimary.copyWith(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────
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