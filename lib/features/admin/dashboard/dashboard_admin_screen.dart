import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/core/constants.dart';
import '../product/daftar_produk_stok_screen.dart';
import '../verification/verifikasi_pesanan_screen.dart';
import 'package:sayurku_kelompok6/features/admin/verification/detail_pesanan_screen.dart';
import 'package:sayurku_kelompok6/features/admin/verification/detail_topup_screen.dart';
import '../../../services/auth_service.dart';
import '../../../services/order_service.dart';
import '../../../services/wallet_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/profil_admin_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  String _chartFilter = 'Mingguan';

  Stream<List<Map<String, dynamic>>>? _ordersStream;
  Stream<List<Map<String, dynamic>>>? _topUpStream;

  final Set<String> _hiddenNotifs = {};

  @override
  void initState() {
    super.initState();
    _ordersStream = OrderService().getAllPesananAdmin();
    _topUpStream = WalletService().getSemuaTopUpAdmin();
    _loadHiddenNotifs();
  }

  Future<void> _loadHiddenNotifs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(AppConstants.colUsers)
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('hidden_notifs')) {
            setState(() {
              _hiddenNotifs.addAll(List<String>.from(data['hidden_notifs']));
            });
          }
        }
      } catch (e) {
        debugPrint("Gagal memuat memori notifikasi: $e");
      }
    }
  }

  String _getCurrentDate() {
    final date = DateTime.now();
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
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatRupiah(double nominal) {
    return 'Rp ${nominal.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Admin?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
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

  void _showNotificationSheet(List<Map<String, dynamic>> notifs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAF7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Notifikasi', style: AppTextStyles.h2),
                        if (notifs.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              final ids = notifs
                                  .map((n) => n['id'].toString())
                                  .toList();

                              setState(() {
                                _hiddenNotifs.addAll(ids);
                              });

                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                FirebaseFirestore.instance
                                    .collection(AppConstants.colUsers)
                                    .doc(user.uid)
                                    .update({
                                      'hidden_notifs': FieldValue.arrayUnion(
                                        ids,
                                      ),
                                    });
                              }

                              setSheetState(() => notifs.clear());
                            },
                            child: Text(
                              'Tandai Dibaca',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: notifs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_off_outlined,
                                  size: 64,
                                  color: AppColors.textHint,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada notifikasi baru',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: notifs.length,
                            itemBuilder: (context, index) {
                              final notif = notifs[index];
                              return Dismissible(
                                key: Key(notif['id']),
                                direction: DismissDirection.horizontal,
                                onDismissed: (direction) {
                                  final id = notif['id'].toString();

                                  setState(() => _hiddenNotifs.add(id));

                                  // 👇 Simpan permanen ke Firebase saat di-swipe
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    FirebaseFirestore.instance
                                        .collection(AppConstants.colUsers)
                                        .doc(user.uid)
                                        .update({
                                          'hidden_notifs':
                                              FieldValue.arrayUnion([id]),
                                        });
                                  }

                                  setSheetState(() => notifs.removeAt(index));
                                },
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: AppColors.white,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (notif['type'] == 'order') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailPesananScreen(
                                            orderId: notif['id'],
                                          ),
                                        ),
                                      );
                                    } else if (notif['type'] == 'topup') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetailVerifikasiTopupScreen(
                                                txId: notif['id'],
                                                userId: notif['userId'],
                                                docPath: notif['docPath'],
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.inputBorder,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: notif['color'].withOpacity(
                                              0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            notif['icon'],
                                            color: notif['color'],
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notif['title'],
                                                style: AppTextStyles.h3
                                                    .copyWith(fontSize: 14),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                notif['subtitle'],
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _getTimeAgo(notif['timestamp']),
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                      color: AppColors.textHint,
                                                      fontSize: 10,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.textHint,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardPage(),
          OrderVerificationPage(
            onMenuTap: (index) => setState(() => _selectedIndex = index),
          ),
          const ProductStockPage(),
          ProfilAdminScreen(
            drawer: _buildAdminDrawer(),
            ordersStream: _ordersStream,
            topUpStream: _topUpStream,
            hiddenNotifs: _hiddenNotifs,
            onShowNotifications: _showNotificationSheet,
            onLogout: _showLogoutDialog,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.white,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined),
              activeIcon: Icon(Icons.verified_user),
              label: 'Verifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Produk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

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
              setState(() => _selectedIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.textPrimary,
            ),
            title: const Text('Verifikasi'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 1);
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
              setState(() => _selectedIndex = 2);
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

  Widget _buildDashboardPage() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _ordersStream,
      builder: (context, orderSnapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _topUpStream,
          builder: (context, topUpSnapshot) {
            final bool isOrderLoading =
                orderSnapshot.connectionState == ConnectionState.waiting &&
                !orderSnapshot.hasData;
            final bool isTopUpLoading =
                topUpSnapshot.connectionState == ConnectionState.waiting &&
                !topUpSnapshot.hasData;

            if (isOrderLoading || isTopUpLoading) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8FAF7),
                drawer: _buildAdminDrawer(),
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Text(
                    'SayurKu Admin',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  centerTitle: false,
                ),
                body: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              );
            }

            final allOrders = orderSnapshot.data ?? [];
            final allTopUps = topUpSnapshot.data ?? [];

            int activeOrders = 0;
            int completedOrders = 0;
            int pendingTopUps = 0;
            double revenueToday = 0;
            double revenueTotalFiltered = 0;
            List<Map<String, dynamic>> unreadNotifs = [];
            final now = DateTime.now();
            List<double> chartData = _chartFilter == 'Mingguan'
                ? List.filled(7, 0.0)
                : List.filled(6, 0.0);

            for (var order in allOrders) {
              final String orderId = order['id'] ?? '';
              final status = (order['status'] ?? '').toString().toLowerCase();
              final harga = (order['totalHarga'] ?? 0).toDouble();
              final timestamp = order['tanggalPesan'] as Timestamp?;

              if (status != 'selesai' && status != 'dibatalkan') {
                activeOrders++;
                if (status == 'menunggu konfirmasi' || status == 'diproses') {
                  if (!_hiddenNotifs.contains(orderId)) {
                    unreadNotifs.add({
                      'type': 'order',
                      'id': orderId,
                      'userId': order['userId'],
                      'title': 'Pesanan Perlu Diproses',
                      'subtitle':
                          'Ada pesanan #${orderId.length > 8 ? orderId.substring(0, 8) : orderId} yang menunggu aksi dari admin.',
                      'timestamp': timestamp,
                      'icon': Icons.shopping_bag,
                      'color': const Color(0xFFE67E22),
                    });
                  }
                }
              } else if (status == 'selesai') {
                completedOrders++;
                if (timestamp != null) {
                  final date = timestamp.toDate();
                  if (date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day)
                    revenueToday += harga;
                  if (_chartFilter == 'Mingguan') {
                    if (now.difference(date).inDays < 7) {
                      revenueTotalFiltered += harga;
                      int dayIndex = date.weekday - 1;
                      chartData[dayIndex] += harga;
                    }
                  } else {
                    if (date.year == now.year &&
                        date.month == now.month &&
                        date.day == now.day) {
                      revenueTotalFiltered += harga;
                      int interval = date.hour ~/ 4;
                      if (interval >= 0 && interval < 6)
                        chartData[interval] += harga;
                    }
                  }
                }
              }
            }

            for (var tx in allTopUps) {
              final String txId = tx['id'] ?? '';
              final String docPath = tx['docPath'] ?? '';
              final status = (tx['status'] ?? '').toString().toLowerCase();
              if (status == 'pending' ||
                  status == AppConstants.txStatusPending.toLowerCase()) {
                pendingTopUps++;
                if (!_hiddenNotifs.contains(txId)) {
                  unreadNotifs.add({
                    'type': 'topup',
                    'id': txId,
                    'userId': tx['userId'],
                    'docPath': docPath,
                    'title': 'Permintaan Isi Saldo',
                    'subtitle':
                        'Seseorang baru saja mengajukan top-up. Segera periksa bukti transfernya.',
                    'timestamp': tx['timestamp'],
                    'icon': Icons.account_balance_wallet,
                    'color': AppColors.primaryGreen,
                  });
                }
              }
            }

            unreadNotifs.sort((a, b) {
              Timestamp? tA = a['timestamp'];
              Timestamp? tB = b['timestamp'];
              if (tA == null || tB == null) return 0;
              return tB.compareTo(tA);
            });
            bool hasUnreadNotifications = unreadNotifs.isNotEmpty;

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAF7),
              drawer: _buildAdminDrawer(),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                title: Text(
                  'SayurKu Admin',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primaryGreen,
                          ),
                          onPressed: () {
                            _showNotificationSheet(unreadNotifs);
                          },
                        ),
                        if (hasUnreadNotifications)
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, Admin!',
                              style: AppTextStyles.h2.copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getCurrentDate(),
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedIndex = 3);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGreen,
                                width: 2,
                              ),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: AppColors.inputBackground,
                              child: Icon(
                                Icons.person,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStatCard(
                            Icons.payments_outlined,
                            _formatRupiah(revenueToday),
                            'Pendapatan Hari Ini',
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickStatCard(
                            Icons.shopping_bag_outlined,
                            '$activeOrders',
                            'Pesanan Aktif',
                            const Color(0xFFE67E22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStatCard(
                            Icons.account_balance_wallet_outlined,
                            '$pendingTopUps',
                            'Antrean Top-Up',
                            AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickStatCard(
                            Icons.check_circle_outline,
                            '$completedOrders',
                            'Pesanan Selesai',
                            AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildSectionTitle(
                            'Grafik Penjualan',
                            Icons.analytics,
                          ),
                        ),
                        _buildChartToggle(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInteractiveChart(chartData, revenueTotalFiltered),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Aktivitas Terbaru', Icons.history),
                    const SizedBox(height: 16),
                    _buildRecentActivityList(allOrders, allTopUps),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.h3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontSize: value.length > 8 ? 16 : 20,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [_buildToggleItem('Harian'), _buildToggleItem('Mingguan')],
      ),
    );
  }

  Widget _buildToggleItem(String label) {
    final isActive = _chartFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _chartFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.white : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveChart(
    List<double> chartData,
    double totalFilteredRevenue,
  ) {
    final isMingguan = _chartFilter == 'Mingguan';
    final labels = isMingguan
        ? ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
        : ['04:00', '08:00', '12:00', '16:00', '20:00', '24:00'];
    final maxHeight = 150.0;
    double maxVal = chartData.reduce((curr, next) => curr > next ? curr : next);
    if (maxVal == 0) maxVal = 1;
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            isMingguan
                ? 'Total Pendapatan (7 Hari Terakhir)'
                : 'Total Pendapatan (Hari Ini)',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 4),
          Text(_formatRupiah(totalFilteredRevenue), style: AppTextStyles.h1),
          const SizedBox(height: 24),
          SizedBox(
            height: maxHeight + 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(chartData.length, (index) {
                final height = (chartData[index] / maxVal) * maxHeight;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      width: isMingguan ? 24 : 32,
                      height: height == 0 ? 4 : height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryGreen.withOpacity(0.5),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(
    List<Map<String, dynamic>> orders,
    List<Map<String, dynamic>> topUps,
  ) {
    List<Map<String, dynamic>> activities = [];
    for (var o in orders) {
      activities.add({
        'type': 'order',
        'userId': o['userId'],
        'title': 'Pesanan ${o['status'].toString().toUpperCase()}',
        'amount': (o['totalHarga'] ?? 0).toDouble(),
        'id': o['id'] ?? '',
        'timestamp': o['tanggalPesan'],
        'status': (o['status'] ?? '').toString().toLowerCase(),
      });
    }
    for (var tx in topUps) {
      activities.add({
        'type': 'topup',
        'userId': tx['userId'],
        'title': 'Top-Up ${tx['status'].toString().toUpperCase()}',
        'amount': (tx['amount'] ?? 0).toDouble(),
        'id': tx['id'] ?? '',
        'timestamp': tx['timestamp'],
        'status': (tx['status'] ?? '').toString().toLowerCase(),
      });
    }
    activities.sort((a, b) {
      Timestamp? tA = a['timestamp'];
      Timestamp? tB = b['timestamp'];
      if (tA == null || tB == null) return 0;
      return tB.compareTo(tA);
    });
    final recentActs = activities.take(5).toList();
    if (recentActs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Belum ada aktivitas terekam.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
        ),
      );
    }
    return Column(
      children: recentActs.map((act) {
        IconData icon = Icons.receipt_long;
        Color color = AppColors.textSecondary;
        if (act['type'] == 'order') {
          if (act['status'] == 'selesai') {
            icon = Icons.check_circle;
            color = AppColors.success;
          } else if (act['status'] == 'dibatalkan') {
            icon = Icons.cancel;
            color = AppColors.error;
          } else {
            icon = Icons.shopping_bag;
            color = const Color(0xFFE67E22);
          }
        } else {
          icon = Icons.account_balance_wallet;
          if (act['status'] == 'approved') {
            color = AppColors.success;
          } else if (act['status'] == 'rejected') {
            color = AppColors.error;
          } else {
            color = AppColors.primaryGreen;
          }
        }
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection(AppConstants.colUsers)
              .doc(act['userId'])
              .get(),
          builder: (context, userSnap) {
            String nama = 'Memuat...';
            if (userSnap.hasData && userSnap.data!.exists) {
              nama =
                  (userSnap.data!.data()
                      as Map<String, dynamic>)['namaLengkap'] ??
                  'Customer';
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act['title'],
                          style: AppTextStyles.h3.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$nama • ${_formatRupiah(act['amount'])}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _getTimeAgo(act['timestamp']),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
