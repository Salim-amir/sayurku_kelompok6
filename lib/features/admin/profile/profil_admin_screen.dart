import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/core/constants.dart';
import 'edit_data_admin_screen.dart';
import '../../customer/profile/ganti_password_screen.dart';

class ProfilAdminScreen extends StatelessWidget {
  final Widget drawer;
  final Stream<List<Map<String, dynamic>>>? ordersStream;
  final Stream<List<Map<String, dynamic>>>? topUpStream;
  final Set<String> hiddenNotifs;
  final Function(List<Map<String, dynamic>>) onShowNotifications;
  final VoidCallback onLogout;

  const ProfilAdminScreen({
    Key? key,
    required this.drawer,
    required this.ordersStream,
    required this.topUpStream,
    required this.hiddenNotifs,
    required this.onShowNotifications,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final role = 'Admin Pengepul';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      drawer: drawer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Text(
          'Profil Admin',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance
                  .collection(AppConstants.colUsers)
                  .doc(user.uid)
                  .snapshots()
            : const Stream.empty(),
        builder: (context, userSnapshot) {
          String namaAdmin = 'Memuat...';
          String noHpAdmin = '';
          String emailAdmin = user?.email ?? 'admin@sayurku.com';

          if (userSnapshot.hasData &&
              userSnapshot.data != null &&
              userSnapshot.data!.exists) {
            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            if (userData != null) {
              namaAdmin = userData['namaLengkap'] ?? 'Admin SayurKu';
              noHpAdmin = userData['nomorHp'] ?? '';
              emailAdmin = userData['email'] ?? emailAdmin;
            }
          } else if (userSnapshot.connectionState != ConnectionState.waiting) {
            namaAdmin = 'Admin SayurKu';
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: ordersStream,
            builder: (context, orderSnapshot) {
              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: topUpStream,
                builder: (context, topUpSnapshot) {
                  final bool isOrderLoading =
                      orderSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !orderSnapshot.hasData;
                  final bool isTopUpLoading =
                      topUpSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !topUpSnapshot.hasData;

                  if (isOrderLoading || isTopUpLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    );
                  }

                  final allOrders = orderSnapshot.data ?? [];
                  final allTopUps = topUpSnapshot.data ?? [];

                  int totalTransaksi = allOrders
                      .where(
                        (o) =>
                            (o['status'] ?? '').toString().toLowerCase() !=
                            'dibatalkan',
                      )
                      .length;
                  List<Map<String, dynamic>> unreadNotifs = [];

                  for (var order in allOrders) {
                    final String orderId = order['id'] ?? '';
                    final status = (order['status'] ?? '')
                        .toString()
                        .toLowerCase();
                    final timestamp = order['tanggalPesan'] as Timestamp?;

                    if (status == 'menunggu konfirmasi' ||
                        status == 'diproses') {
                      if (!hiddenNotifs.contains(orderId)) {
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
                  }

                  for (var tx in allTopUps) {
                    final String txId = tx['id'] ?? '';
                    final String docPath = tx['docPath'] ?? '';
                    final status = (tx['status'] ?? '')
                        .toString()
                        .toLowerCase();

                    if (status == 'pending' ||
                        status == AppConstants.txStatusPending.toLowerCase()) {
                      if (!hiddenNotifs.contains(txId)) {
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

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // ── 1. AVATAR & NAMA ──
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                color: Colors.grey.shade300,
                                image: const DecorationImage(
                                  image: AssetImage(
                                    'assets/images/default_avatar.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          namaAdmin,
                          style: AppTextStyles.h2.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── 2. CARD TOTAL TRANSAKSI ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5EF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL TRANSAKSI',
                                style: AppTextStyles.labelUppercase.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                totalTransaksi.toString().replaceAllMapped(
                                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                                  (m) => '${m[1]},',
                                ),
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: 22,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── 3. MANAJEMEN SECTION ──
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'MANAJEMEN',
                            style: AppTextStyles.labelUppercase.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(
                                icon: Icons.person_rounded,
                                label: 'Edit Data Diri',
                                iconColor: AppColors.primaryGreen,
                                iconBgColor: AppColors.primaryGreen.withOpacity(
                                  0.1,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditDataAdminScreen(
                                        userData: {
                                          'namaLengkap': namaAdmin,
                                          'nomorHp': noHpAdmin,
                                          'email': emailAdmin,
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildDivider(),

                              _buildMenuItem(
                                icon: Icons.notifications_none_rounded,
                                label: 'Notifikasi',
                                iconColor: AppColors.primaryGreen,
                                iconBgColor: AppColors.primaryGreen.withOpacity(
                                  0.1,
                                ),
                                onTap: () {
                                  onShowNotifications(unreadNotifs);
                                },
                                hasBadge: unreadNotifs.isNotEmpty,
                              ),
                              _buildDivider(),

                              _buildMenuItem(
                                icon: Icons.lock_outline_rounded,
                                label: 'Ganti Password',
                                iconColor: AppColors.primaryGreen,
                                iconBgColor: AppColors.primaryGreen.withOpacity(
                                  0.1,
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const GantiPasswordScreen(),
                                  ),
                                ),
                              ),
                              _buildDivider(),

                              _buildMenuItem(
                                icon: Icons.logout_rounded,
                                label: 'Keluar (Logout)',
                                iconColor: AppColors.error,
                                iconBgColor: AppColors.error.withOpacity(0.1),
                                textColor: AppColors.error,
                                isLogout: true,
                                onTap: onLogout,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ── HELPER WIDGETS UNTUK PROFIL ──
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    Color? textColor,
    bool hasBadge = false,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                if (hasBadge)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              isLogout
                  ? Icons.exit_to_app_rounded
                  : Icons.chevron_right_rounded,
              color: isLogout
                  ? AppColors.error.withOpacity(0.5)
                  : AppColors.textHint,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 80, right: 20),
      child: Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
    );
  }
}
