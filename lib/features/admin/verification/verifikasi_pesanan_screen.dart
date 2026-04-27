import 'package:flutter/material.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';

class OrderVerificationPage extends StatefulWidget {
  const OrderVerificationPage({Key? key}) : super(key: key);

  @override
  State<OrderVerificationPage> createState() => _OrderVerificationPageState();
}

class _OrderVerificationPageState extends State<OrderVerificationPage> {
  int _selectedTabIndex = 0; // Pesanan tab

  // Sample data pesanan
  final List<OrderModel> orders = [
    OrderModel(
      id: 'ORD-102',
      sellerName: 'Ibu Sari',
      sellerAvatar: 'assets/avatars/ibu_sari.jpg',
      status: 'MENUNGGU VERIFIKASI',
      timeAgo: '2 menit',
      totalPrice: 45000,
      description: 'Sayur Segar Pagi Ini',
    ),
    OrderModel(
      id: 'ORD-101',
      sellerName: 'Pak Budi',
      sellerAvatar: 'assets/avatars/pak_budi.jpg',
      status: 'MENUNGGU VERIFIKASI',
      timeAgo: '10 menit',
      totalPrice: 122500,
      description: 'Paket Hemat Sayuran',
    ),
    OrderModel(
      id: 'ORD-100',
      sellerName: 'Mbak Anita',
      sellerAvatar: 'assets/avatars/mbak_anita.jpg',
      status: 'MENUNGGU VERIFIKASI',
      timeAgo: '28 menit',
      totalPrice: 76200,
      description: 'Sayuran Organik Premium',
    ),
    OrderModel(
      id: 'ORD-099',
      sellerName: 'Pak Adi',
      sellerAvatar: 'assets/avatars/pak_adi.jpg',
      status: 'MENUNGGU VERIFIKASI',
      timeAgo: '45 menit',
      totalPrice: 89500,
      description: 'Sayuran Segar Hari Ini',
    ),
    OrderModel(
      id: 'ORD-098',
      sellerName: 'Ibu Dewi',
      sellerAvatar: 'assets/avatars/ibu_dewi.jpg',
      status: 'MENUNGGU VERIFIKASI',
      timeAgo: '1 jam',
      totalPrice: 156000,
      description: 'Paket Lengkap Sayuran',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ─── APP BAR ───────────────────────────────────────
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
      // ─── BODY ───────────────────────────────────────────
      body: CustomScrollView(
        slivers: [
          // ─ Tab Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Pesanan Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedTabIndex = 0);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0
                              ? AppColors.primaryGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: _selectedTabIndex == 0
                              ? null
                              : Border.all(
                                  color: AppColors.divider,
                                  width: 1,
                                ),
                        ),
                        child: Center(
                          child: Text(
                            'Pesanan',
                            style: AppTextStyles.buttonSecondary.copyWith(
                              color: _selectedTabIndex == 0
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Isi Saldo Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedTabIndex = 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1
                              ? AppColors.primaryGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: _selectedTabIndex == 1
                              ? null
                              : Border.all(
                                  color: AppColors.divider,
                                  width: 1,
                                ),
                        ),
                        child: Center(
                          child: Text(
                            'Isi Saldo',
                            style: AppTextStyles.buttonSecondary.copyWith(
                              color: _selectedTabIndex == 1
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─ Dashboard Card (Pesanan Tab Only)
          if (_selectedTabIndex == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDashboardCard(),
              ),
            ),

          // ─ Search Bar (Pesanan Tab Only)
          if (_selectedTabIndex == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Pesanan...',
                    hintStyle: AppTextStyles.inputHint,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textHint,
                      size: 18,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.inputBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.inputBorder,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  style: AppTextStyles.inputText,
                ),
              ),
            ),

          // ─ Antrian Terbaru Section (Pesanan Tab Only)
          if (_selectedTabIndex == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Antrean Terbaru',
                      style: AppTextStyles.h3,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.tune, color: AppColors.textPrimary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),

          // ─ Order List (Pesanan Tab Only)
          if (_selectedTabIndex == 0)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = orders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildOrderCard(order),
                    );
                  },
                  childCount: orders.length,
                ),
              ),
            ),

          // ─ Isi Saldo Tab Content (Placeholder)
          if (_selectedTabIndex == 1)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Fitur Isi Saldo Akan Segera Tersedia',
                    style: AppTextStyles.h3,
                  ),
                ),
              ),
            ),

          // ─ Bottom Spacing
          SliverToBoxAdapter(
            child: const SizedBox(height: 20),
          ),
        ],
      ),
      // ─────────────────────────────────────────────────────
      // PENTING: TIDAK ADA bottomNavigationBar DI SINI
      // Navigation diatur oleh parent AdminDashboard
      // ─────────────────────────────────────────────────────
    );
  }

  // ─── DASHBOARD CARD WIDGET ───────────────────────────
  Widget _buildDashboardCard() {
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
          // ─ Label
          Text(
            'DASHBOARD ADMIN',
            style: AppTextStyles.labelUppercase.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          // ─ Title
          Text(
            'Total Antrian Hari Ini: ${orders.length} Pesanan',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          // ─ Message with Icon
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Semua sayuran siap dikiemasi!',
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

  // ─── ORDER CARD WIDGET ───────────────────────────────
  Widget _buildOrderCard(OrderModel order) {
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
          // ─ Seller Info
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.inputBackground,
                child: Icon(
                  Icons.person,
                  color: AppColors.textHint,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Name & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.sellerName,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          order.id,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${order.timeAgo}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.status,
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
          // ─ Total Pesanan
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL PESANAN',
                style: AppTextStyles.labelUppercase,
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${order.totalPrice.toString().replaceAllMapped(
                      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                      (match) => '${match.group(1)}.',
                    )}',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ─ Detail Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Detail ${order.id} - ${order.sellerName}'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Detail',
                style: AppTextStyles.buttonPrimary.copyWith(
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ─────────── ORDER MODEL ────────────────────────────────
// ─────────────────────────────────────────────────────────

class OrderModel {
  final String id;
  final String sellerName;
  final String sellerAvatar;
  final String status;
  final String timeAgo;
  final int totalPrice;
  final String description;

  OrderModel({
    required this.id,
    required this.sellerName,
    required this.sellerAvatar,
    required this.status,
    required this.timeAgo,
    required this.totalPrice,
    required this.description,
  });
}