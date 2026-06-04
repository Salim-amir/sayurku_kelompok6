import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/core/constants.dart';
import 'package:sayurku_kelompok6/services/order_service.dart';
import 'package:sayurku_kelompok6/features/admin/verification/detail_pesanan_screen.dart';
import 'verifikasi_isi_saldo_screen.dart';
import '../../../services/auth_service.dart';

class OrderVerificationPage extends StatefulWidget {
  // 👇 INI REMOTE CONTROL-NYA 👇
  final Function(int)? onMenuTap;

  const OrderVerificationPage({Key? key, this.onMenuTap}) : super(key: key);

  @override
  State<OrderVerificationPage> createState() => _OrderVerificationPageState();
}

class _OrderVerificationPageState extends State<OrderVerificationPage> {
  int _selectedTabIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Menunggu Konfirmasi';
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  
  late ScrollController _scrollController;
  late Stream<List<Map<String, dynamic>>> _ordersStream;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ordersStream = OrderService().getAllPesananAdmin();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _colorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi':
        return const Color(0xFFC41E3A);
      case 'diproses':
      case 'dikirim':
        return const Color(0xFFE67E22);
      case 'selesai':
        return AppColors.success;
      case 'dibatalkan':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Admin?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthService().logoutUser();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Ya, Logout',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SIDEBAR (DRAWER) ───
  Widget _buildAdminDrawer() {
    return Drawer(
      backgroundColor: AppColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.white,
                  radius: 30,
                  child: Icon(
                    Icons.person,
                    color: AppColors.primaryGreen,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin SayurKu',
                  style: AppTextStyles.h3.copyWith(color: AppColors.white),
                ),
                Text(
                  'Pusat Kendali Toko',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.dashboard_outlined,
              color: AppColors.textPrimary,
            ),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              if (widget.onMenuTap != null)
                widget.onMenuTap!(0); // 👈 Lompat ke Dashboard
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.primaryGreen,
            ),
            title: const Text(
              'Verifikasi',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Tetap di sini
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.textPrimary,
            ),
            title: const Text('Produk'),
            onTap: () {
              Navigator.pop(context);
              if (widget.onMenuTap != null)
                widget.onMenuTap!(2); // 👈 Lompat ke Produk
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Verifikasi Antrean',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          final allOrders = snapshot.data ?? [];
          final List<Map<String, dynamic>> filtered = _selectedFilter == 'Semua'
              ? allOrders
              : allOrders.where((o) {
                  final s = (o['status'] ?? '').toString().toLowerCase();
                  return s == _selectedFilter.toLowerCase();
                }).toList();

          final int totalPages = (filtered.length / _itemsPerPage).ceil() == 0 ? 1 : (filtered.length / _itemsPerPage).ceil();
          
          if (_currentPage > totalPages) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
               if(mounted) setState(() => _currentPage = totalPages);
            });
          }

          final int startIndex = (_currentPage - 1) * _itemsPerPage;
          final int endIndex = (startIndex + _itemsPerPage > filtered.length)
              ? filtered.length
              : startIndex + _itemsPerPage;
          
          final List<Map<String, dynamic>> paginated = startIndex < filtered.length ? filtered.sublist(startIndex, endIndex) : [];

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      _buildTab(label: 'Pesanan', index: 0),
                      const SizedBox(width: 12),
                      _buildTab(label: 'Isi Saldo', index: 1),
                    ],
                  ),
                ),
              ),

              if (_selectedTabIndex == 0) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildDashboardCard(filtered.length),
                  ),
                ),
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
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textHint,
                          size: 18,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                          ),
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
                                  : _selectedFilter == 'Semua'
                                  ? 'Semua Pesanan'
                                  : 'Pesanan Terbaru',
                              style: AppTextStyles.h3,
                            ),
                            if (_selectedFilter != 'Menunggu Konfirmasi')
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
                            color: _selectedFilter == 'Menunggu Konfirmasi'
                                ? AppColors.textPrimary
                                : AppColors.primaryGreen,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (v) {
                            setState(() {
                              _selectedFilter = v;
                              _currentPage = 1;
                            });
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'Menunggu Konfirmasi',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.pending_outlined,
                                    size: 18,
                                    color:
                                        _selectedFilter == 'Menunggu Konfirmasi'
                                        ? AppColors.primaryGreen
                                        : AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Menunggu Konfirmasi'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'Diproses',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.autorenew_outlined,
                                    size: 18,
                                    color: _selectedFilter == 'Diproses'
                                        ? AppColors.primaryGreen
                                        : AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Diproses'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'Dikirim',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping_outlined,
                                    size: 18,
                                    color: _selectedFilter == 'Dikirim'
                                        ? AppColors.primaryGreen
                                        : AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Dikirim'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'Selesai',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                    color: _selectedFilter == 'Selesai'
                                        ? AppColors.primaryGreen
                                        : AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Riwayat: Selesai'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'Dibatalkan',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    size: 18,
                                    color: _selectedFilter == 'Dibatalkan'
                                        ? AppColors.primaryGreen
                                        : AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Riwayat: Dibatalkan'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'Semua',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.list_alt_outlined,
                                    size: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Tampilkan Semua'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                filtered.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.inbox_outlined,
                                  size: 56,
                                  color: AppColors.textHint,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada pesanan.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
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
                            final orderData = paginated[index];
                            final userId = orderData['userId'] ?? '';
                            final orderId = orderData['id'] ?? '';
                            final status =
                                (orderData['status'] ?? 'MENUNGGU KONFIRMASI')
                                    .toString();
                            final totalHarga = (orderData['totalHarga'] ?? 0)
                                .toInt();
                            final timestamp =
                                orderData['tanggalPesan'] as Timestamp?;

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection(AppConstants.colUsers)
                                  .doc(userId)
                                  .get(),
                              builder: (context, userSnap) {
                                String namaUser = 'Memuat...';
                                String fotoUrl = '';
                                if (userSnap.hasData && userSnap.data!.exists) {
                                  final ud =
                                      userSnap.data!.data()
                                          as Map<String, dynamic>;
                                  namaUser = ud['namaLengkap'] ?? 'Customer';
                                  fotoUrl = ud['fotoUrl'] ?? ud['photoUrl'] ?? '';
                                }

                                if (_searchQuery.isNotEmpty &&
                                    !namaUser.toLowerCase().contains(
                                      _searchQuery,
                                    )) {
                                  return const SizedBox.shrink();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildOrderCard(
                                    orderId: orderId,
                                    namaUser: namaUser,
                                    fotoUrl: fotoUrl,
                                    status: status,
                                    timeAgo: _getTimeAgo(timestamp),
                                    totalHarga: totalHarga,
                                  ),
                                );
                              },
                            );
                          }, childCount: paginated.length),
                        ),
                      ),
                      
                if (_selectedTabIndex == 0 && filtered.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() => _currentPage--);
                                    _scrollToTop();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              disabledBackgroundColor: AppColors.divider,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('< Prev', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Hal $_currentPage dari $totalPages',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _currentPage < totalPages
                                ? () {
                                    setState(() => _currentPage++);
                                    _scrollToTop();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              disabledBackgroundColor: AppColors.divider,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Next >', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],

              if (_selectedTabIndex == 1)
                const SliverFillRemaining(child: VerifikasiIsiSaldoPage()),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }

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
              Icons.shopping_basket_rounded,
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
                  '$total Pesanan',
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
                        'Semua pesanan sayuran segar siap dikemas!',
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

  Widget _buildOrderCard({
    required String orderId,
    required String namaUser,
    required String fotoUrl,
    required String status,
    required String timeAgo,
    required int totalHarga,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailPesananScreen(orderId: orderId),
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
                        '#${orderId.length > 8 ? orderId.substring(0, 8) : orderId} • $timeAgo',
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
                    status.toUpperCase(),
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
                    Text('Total Pesanan', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${totalHarga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
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
}

String _getTimeAgo(Timestamp? timestamp) {
  if (timestamp == null) return 'Baru saja';
  final diff = DateTime.now().difference(timestamp.toDate());
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  return '${diff.inDays} hari lalu';
}
