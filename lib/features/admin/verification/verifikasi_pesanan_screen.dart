import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/core/constants.dart';
import 'package:sayurku_kelompok6/services/order_service.dart';
import 'package:sayurku_kelompok6/features/admin/verification/detail_pesanan_screen.dart';
import 'verifikasi_isi_saldo_screen.dart';

class OrderVerificationPage extends StatefulWidget {
  const OrderVerificationPage({Key? key}) : super(key: key);

  @override
  State<OrderVerificationPage> createState() => _OrderVerificationPageState();
}

class _OrderVerificationPageState extends State<OrderVerificationPage> {
  int _selectedTabIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  // ── Stream dikunci di initState — tidak reload saat rebuild ──
  late Stream<List<Map<String, dynamic>>> _ordersStream;

  @override
  void initState() {
    super.initState();
    // Tarik SEMUA pesanan sekaligus — filter dilakukan di client
    _ordersStream = OrderService().getAllPesananAdmin();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        title: Text(
          'Pesanan Masuk',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      // ── StreamBuilder membungkus SEMUA body ─────────────────────
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          final allOrders = snapshot.data ?? [];

          // ── Logika filter status ─────────────────────────────────
          final List<Map<String, dynamic>> filtered;
          if (_selectedFilter == 'Semua') {
            // Default: tampilkan semua yang AKTIF (bukan Selesai/Dibatalkan)
            filtered = allOrders.where((o) {
              final s = (o['status'] ?? '').toString().toLowerCase();
              return s != 'selesai' && s != 'dibatalkan';
            }).toList();
          } else {
            // Filter spesifik — termasuk Selesai & Dibatalkan untuk riwayat
            filtered = allOrders.where((o) {
              final s = (o['status'] ?? '').toString().toLowerCase();
              return s == _selectedFilter.toLowerCase();
            }).toList();
          }

          return CustomScrollView(
            slivers: [
              // ─── TAB BAR ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      _buildTab(label: 'Pesanan', index: 0),
                      const SizedBox(width: 12),
                      _buildTab(label: 'Isi Saldo', index: 1),
                    ],
                  ),
                ),
              ),

              // ─── PESANAN TAB ─────────────────────────────────────
              if (_selectedTabIndex == 0) ...[
                // Dashboard Card — angka dinamis dari filtered.length
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildDashboardCard(filtered.length),
                  ),
                ),

                // Search Bar
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

                // Judul Section + Popup Filter
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
                              (_selectedFilter == 'Selesai' ||
                                      _selectedFilter == 'Dibatalkan')
                                  ? 'Riwayat Pesanan'
                                  : 'Pesanan Terbaru',
                              style: AppTextStyles.h3,
                            ),
                            if (_selectedFilter != 'Semua')
                              Text(
                                'Filter: $_selectedFilter',
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
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'Semua',
                                child: Text('Tampilkan Semua (Aktif)')),
                            PopupMenuItem(
                                value: 'Menunggu Konfirmasi',
                                child: Text('Menunggu Konfirmasi')),
                            PopupMenuItem(
                                value: 'Diproses',
                                child: Text('Diproses')),
                            PopupMenuItem(
                                value: 'Dikirim',
                                child: Text('Dikirim')),
                            PopupMenuItem(
                                value: 'Selesai',
                                child: Text('Riwayat: Selesai')),
                            PopupMenuItem(
                                value: 'Dibatalkan',
                                child: Text('Riwayat: Dibatalkan')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Order List
                filtered.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 56, color: AppColors.textHint),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada pesanan.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final orderData = filtered[index];
                              final userId = orderData['userId'] ?? '';
                              final orderId = orderData['id'] ?? '';
                              final status =
                                  (orderData['status'] ?? 'MENUNGGU KONFIRMASI')
                                      .toString()
                                      .toUpperCase();
                              final totalHarga =
                                  (orderData['totalHarga'] ?? 0).toInt();
                              final timestamp =
                                  orderData['tanggalPesan'] as Timestamp?;

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
                                    child: _buildOrderCard(
                                      orderId: orderId,
                                      namaUser: namaUser,
                                      status: status,
                                      timeAgo: _getTimeAgo(timestamp),
                                      totalHarga: totalHarga,
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      ),
              ],

              // ─── ISI SALDO TAB ───────────────────────────────────
              if (_selectedTabIndex == 1)
                const SliverFillRemaining(
                  child: VerifikasiIsiSaldoPage(),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }

  // ─── TAB BUTTON ──────────────────────────────────────────────
  Widget _buildTab({required String label, required int index}) {
    final isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isActive
                ? null
                : Border.all(color: AppColors.divider, width: 1),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.buttonSecondary.copyWith(
                color: isActive ? AppColors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── DASHBOARD CARD — angka ikut filtered.length ─────────────
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
            'Total Pesanan: $total Pesanan',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Semua sayuran siap dikemas!',
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

  // ─── ORDER CARD ──────────────────────────────────────────────
  Widget _buildOrderCard({
    required String orderId,
    required String namaUser,
    required String status,
    required String timeAgo,
    required int totalHarga,
  }) {
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
                            '#${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('• $timeAgo',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFFC41E3A),
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
              Text('TOTAL PESANAN', style: AppTextStyles.labelUppercase),
              const SizedBox(height: 4),
              Text(
                'Rp ${totalHarga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
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
                  builder: (_) =>
                      DetailPesananScreen(orderId: orderId),
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
}

// ─── HELPER WAKTU RELATIF ────────────────────────────────────
String _getTimeAgo(Timestamp? timestamp) {
  if (timestamp == null) return 'Baru saja';
  final diff = DateTime.now().difference(timestamp.toDate());
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  return '${diff.inDays} hari lalu';
}