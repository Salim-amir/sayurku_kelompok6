import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';
import '../../../services/order_service.dart';

class RiwayatPesananScreen extends StatefulWidget {
  const RiwayatPesananScreen({super.key});

  @override
  State<RiwayatPesananScreen> createState() => _RiwayatPesananScreenState();
}

class _RiwayatPesananScreenState extends State<RiwayatPesananScreen>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  final user = FirebaseAuth.instance.currentUser;

  late TabController _tabController;

  final List<String> _tabs = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Dikirim',
    'Selesai',
  ];

  final Map<String, String> _tabToStatus = {
    'Menunggu': AppConstants.statusMenunggu,
    'Diproses': AppConstants.statusDiproses,
    'Dikirim': AppConstants.statusDikirim,
    'Selesai': AppConstants.statusSelesai,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
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
          Text('Riwayat Pesanan',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  // ── TAB BAR ─────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle:
            AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.bodySmall,
        indicator: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.all(4),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  // ── TAB CONTENT ─────────────────────────────────────
  Widget _buildTabContent() {
    if (user == null) {
      return const Center(child: Text('Silakan login terlebih dahulu'));
    }

    return TabBarView(
      controller: _tabController,
      children: _tabs.map((tab) {
        if (tab == 'Semua') {
          return _buildPesananList(
              _orderService.getPesananByUser(user!.uid));
        } else {
          return _buildPesananList(
              _orderService.getPesananByStatus(user!.uid, _tabToStatus[tab]!));
        }
      }).toList(),
    );
  }

  Widget _buildPesananList(Stream<List<Map<String, dynamic>>> stream) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.textHint, size: 48),
                const SizedBox(height: 12),
                Text('Gagal memuat pesanan',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        final pesananList = snapshot.data ?? [];

        if (pesananList.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: pesananList.length,
          itemBuilder: (context, index) {
            return _buildPesananCard(pesananList[index]);
          },
        );
      },
    );
  }

  // ── EMPTY STATE ─────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded,
              color: AppColors.textHint.withOpacity(0.4), size: 72),
          const SizedBox(height: 16),
          Text('Belum Ada Pesanan',
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Pesanan Anda akan muncul di sini',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  // ── PESANAN CARD ────────────────────────────────────
  Widget _buildPesananCard(Map<String, dynamic> pesanan) {
    final status = pesanan['status'] ?? '';
    final items = List<Map<String, dynamic>>.from(pesanan['items'] ?? []);
    final totalHarga = (pesanan['totalHarga'] ?? 0).toDouble();
    final tanggal = pesanan['tanggalPesan']?.toDate();
    final jumlahItem = items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: tanggal + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tanggal != null ? _formatTanggal(tanggal) : '-',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textHint),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),

          // Item list preview
          ...items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.eco_rounded,
                          color: AppColors.primaryGreen, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${item['nama'] ?? 'Produk'} x${item['jumlah'] ?? 1}',
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),

          if (jumlahItem > 2)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+${jumlahItem - 2} produk lainnya',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textHint),
              ),
            ),

          const Divider(height: 20, color: AppColors.divider),

          // Footer: jumlah item + total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$jumlahItem produk',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              Text(
                'Rp ${_formatHarga(totalHarga.toInt())}',
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.primaryGreen, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STATUS BADGE ────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case AppConstants.statusMenunggu:
        bgColor = AppColors.warning.withOpacity(0.12);
        textColor = AppColors.warning;
        break;
      case AppConstants.statusDiproses:
        bgColor = AppColors.info.withOpacity(0.12);
        textColor = AppColors.info;
        break;
      case AppConstants.statusDikirim:
        bgColor = AppColors.primaryGreen.withOpacity(0.12);
        textColor = AppColors.primaryGreen;
        break;
      case AppConstants.statusSelesai:
        bgColor = AppColors.success.withOpacity(0.12);
        textColor = AppColors.success;
        break;
      case AppConstants.statusDibatalkan:
        bgColor = AppColors.error.withOpacity(0.12);
        textColor = AppColors.error;
        break;
      default:
        bgColor = AppColors.textHint.withOpacity(0.12);
        textColor = AppColors.textHint;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTextStyles.bodySmall
            .copyWith(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }

  String _formatTanggal(DateTime date) {
    final bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${bulan[date.month]} ${date.year}';
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
