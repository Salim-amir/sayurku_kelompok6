import 'package:flutter/material.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/features/admin/verification/detail_pesanan_screen.dart';
import '/../services/order_service.dart';
import '/../core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderVerificationPage extends StatefulWidget {
  const OrderVerificationPage({Key? key}) : super(key: key);

  @override
  State<OrderVerificationPage> createState() => _OrderVerificationPageState();
}

class _OrderVerificationPageState extends State<OrderVerificationPage> {
  int _selectedTabIndex = 0; // Pesanan tab

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  // 1. TAMBAHKAN VARIABEL INI
  late Stream<List<Map<String, dynamic>>> _ordersStream;

  // 2. TAMBAHKAN INITSTATE INI
  @override
  void initState() {
    super.initState();
    // Tarik data Firebase sekali saja di awal, bukan setiap kali ngetik
    _ordersStream = OrderService().getSemuaPesananAdmin();
  }

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
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      // ─── BODY (Dibungkus StreamBuilder Agar Kartu Hijau Ikut Dinamis) ───
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allOrders = snapshot.data ?? [];

          // Logika Filter Dinamis
          final orders = _selectedFilter == 'Semua'
              ? allOrders.where((order) {
                  // Jika filter 'Semua', HANYA tampilkan pesanan yang masih AKTIF
                  // Sembunyikan yang sudah 'Selesai' atau 'Dibatalkan'
                  final statusAsli = (order['status'] ?? '')
                      .toString()
                      .toLowerCase();
                  return statusAsli != 'selesai' && statusAsli != 'dibatalkan';
                }).toList()
              : allOrders.where((order) {
                  // Jika pilih filter spesifik (Menunggu, Diproses, dll)
                  final statusAsli = (order['status'] ?? '')
                      .toString()
                      .toLowerCase();
                  return statusAsli == _selectedFilter.toLowerCase();
                }).toList();

          return CustomScrollView(
            slivers: [
              // ─ Tab Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
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
                    child: _buildDashboardCard(
                      orders.length,
                    ), // Angka dikirim ke kartu
                  ),
                ),

              // ─ Search Bar (Pesanan Tab Only)
              if (_selectedTabIndex == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari Berdasarkan Nama...',
                        hintStyle: AppTextStyles.inputHint,
                        prefixIcon: const Icon(
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

              // ─ Antrean Terbaru Section (Pesanan Tab Only)
              if (_selectedTabIndex == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Teks Judul & Indikator Filter Aktif
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFilter == 'Selesai' || _selectedFilter == 'Dibatalkan'
                                  ? 'Riwayat Pesanan'
                                  : 'Pesanan Terbaru',
                              style: AppTextStyles.h3,
                            ),
                            if (_selectedFilter != 'Semua')
                              Text(
                                'Menampilkan: $_selectedFilter',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        // Tombol Popup Filter
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.tune,
                            color: _selectedFilter == 'Semua'
                                ? AppColors.textPrimary
                                : AppColors.primaryGreen,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (String value) {
                            setState(() {
                              _selectedFilter = value;
                            });
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'Semua',
                                  child: Text('Tampilkan Semua (Aktif)'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Menunggu Konfirmasi',
                                  child: Text('Menunggu Konfirmasi'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Diproses',
                                  child: Text('Diproses'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Dikirim',
                                  child: Text('Dikirim'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Selesai',
                                  child: Text('Riwayat: Selesai'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Dibatalkan',
                                  child: Text('Riwayat: Dibatalkan'),
                                ),
                              ],
                        ),
                      ],
                    ),
                  ),
                ),

              // ─ Order List (Pesanan Tab Only)
              if (_selectedTabIndex == 0)
                orders.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('Belum ada pesanan masuk.'),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final orderData = orders[index];
                            final userId = orderData['userId'] ?? '';

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection(AppConstants.colUsers)
                                  .doc(userId)
                                  .get(),
                              builder: (context, userSnapshot) {
                                String namaAsli = 'Memuat...';

                                if (userSnapshot.hasData &&
                                    userSnapshot.data!.exists) {
                                  final userData =
                                      userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                  namaAsli =
                                      userData['namaLengkap'] ?? 'Customer';
                                }

                                // Sembunyikan jika nama tidak cocok dengan pencarian
                                if (_searchQuery.isNotEmpty &&
                                    !namaAsli.toLowerCase().contains(
                                      _searchQuery,
                                    )) {
                                  return const SizedBox.shrink();
                                }

                                final order = OrderModel(
                                  id: orderData['id'] ?? 'ORD-XXX',
                                  sellerName: namaAsli,
                                  sellerAvatar: '',
                                  status:
                                      (orderData['status'] ??
                                              'MENUNGGU KONFIRMASI')
                                          .toString()
                                          .toUpperCase(),
                                  timeAgo: _getTimeAgo(
                                    orderData['tanggalPesan'] as Timestamp?,
                                  ),
                                  totalPrice: (orderData['totalHarga'] ?? 0)
                                      .toInt(),
                                  description: 'Pesanan Customer',
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildOrderCard(order),
                                );
                              },
                            );
                          }, childCount: orders.length),
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

              // ─ Bottom Spacing
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }

  // ─── DASHBOARD CARD WIDGET ───────────────────────────
  Widget _buildDashboardCard(int totalAntrean) {
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
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          // ─ Title (Teks diubah dan jumlah dinamis)
          Text(
            'Total Pesanan: $totalAntrean Pesanan',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          // ─ Message with Icon
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Semua sayuran siap dikiemasi!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
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
                child: const Icon(
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
                    Text(order.sellerName, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              Text('TOTAL PESANAN', style: AppTextStyles.labelUppercase),
              const SizedBox(height: 4),
              Text(
                'Rp ${order.totalPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}',
                style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ─ Detail Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman Detail dengan membawa ID Pesanan
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailPesananScreen(orderId: order.id),
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
                style: AppTextStyles.buttonPrimary.copyWith(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FUNGSI PENGHITUNG WAKTU ─────────────────────────
String _getTimeAgo(Timestamp? timestamp) {
  if (timestamp == null) return 'Baru saja';

  final DateTime orderTime = timestamp.toDate();
  final Duration diff = DateTime.now().difference(orderTime);

  if (diff.inMinutes < 1) {
    return 'Baru saja';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} mnt lalu';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} jam lalu';
  } else {
    return '${diff.inDays} hari lalu';
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
