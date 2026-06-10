import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';
import 'riwayat_pesanan_screen.dart';
import 'dompet_digital_screen.dart';
import 'detail_pesanan_customer_screen.dart';

class NotifikasiScreen extends StatefulWidget {
  final bool showBackButton;
  const NotifikasiScreen({super.key, this.showBackButton = true});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> _getNotifikasi(String userId) {
    return _db
        .collection(AppConstants.colNotifications)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> _tandaiDibaca(String notifId) async {
    await _db.collection(AppConstants.colNotifications).doc(notifId).update({
      'isRead': true,
    });
  }

  // ─── Tandai semua notifikasi menjadi "Sudah Dibaca" sekaligus ───
  Future<void> _tandaiSemuaDibaca() async {
    if (user == null) return;
    try {
      final unreadDocs = await _db
          .collection(AppConstants.colNotifications)
          .where('userId', isEqualTo: user!.uid)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadDocs.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Semua notifikasi sudah dibaca')),
          );
        }
        return;
      }

      // Gunakan Batch agar lebih cepat dan hemat kuota database
      final batch = _db.batch();
      for (var doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print("Gagal menandai semua dibaca: $e");
    }
  }

  Future<void> _hapusNotifikasi(String notifId) async {
    await _db.collection(AppConstants.colNotifications).doc(notifId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildNotifikasiList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.showBackButton ? 8 : 20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.showBackButton)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primaryGreen,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              Text(
                'Notifikasi',
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
              ),
            ],
          ),
          // 👇 TOMBOL TANDAI SEMUA DIBACA 👇
          TextButton(
            onPressed: _tandaiSemuaDibaca,
            child: Text(
              'Tandai Dibaca',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifikasiList() {
    if (user == null) {
      return const Center(child: Text('Silakan login terlebih dahulu'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getNotifikasi(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (snapshot.hasError) {
          print("🚨 BACA ERROR INI KOMANDAN: ${snapshot.error}");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.textHint,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat notifikasi',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final notifList = snapshot.data ?? [];

        if (notifList.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          itemCount: notifList.length,
          itemBuilder: (context, index) =>
              _buildNotifikasiItem(notifList[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: AppColors.textHint.withOpacity(0.4),
            size: 72,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Notifikasi',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi Anda akan muncul di sini',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifikasiItem(Map<String, dynamic> notif) {
    final judul = notif['title'] ?? 'Notifikasi';
    final pesan = notif['message'] ?? '';
    final isRead = notif['isRead'] ?? false;
    final timestamp = notif['timestamp']?.toDate();
    final type = notif['type'] ?? 'info';
    final notifId = notif['id'];

    IconData icon;
    Color iconColor;
    switch (type) {
      case 'order':
        icon = Icons.receipt_long_rounded;
        iconColor = AppColors.info;
        break;
      case 'topup':
        icon = Icons.account_balance_wallet_rounded;
        iconColor = AppColors.success;
        break;
      case 'refund':
        icon = Icons.currency_exchange_rounded;
        iconColor = AppColors.success;
        break;
      case 'promo':
        icon = Icons.local_offer_rounded;
        iconColor = AppColors.warning;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = AppColors.primaryGreen;
    }

    return Dismissible(
      key: Key(notifId),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _hapusNotifikasi(notifId);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          // 1. Ubah status jadi sudah dibaca (Titik hijau hilang)
          if (!isRead) _tandaiDibaca(notifId);

          // 2. Navigasi Cerdas
          if (type == 'order') {
            final pesananId = notif['referenceId'];
            if (pesananId != null) {
              try {
                // Tampilkan loading dialog agar UI tidak terasa 'nge-freeze'
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  ),
                );

                final doc = await FirebaseFirestore.instance
                    .collection(AppConstants.colOrders)
                    .doc(pesananId)
                    .get();

                // Tutup loading dialog
                if (mounted) Navigator.pop(context);

                if (doc.exists && mounted) {
                  final pesananData = {
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  };
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPesananCustomerScreen(pesanan: pesananData),
                    ),
                  );
                  return; // Stop here if success
                }
              } catch (e) {
                if (mounted) Navigator.pop(context); // Tutup loading jika error
                // Fallback will execute
              }
            }
            
            // Fallback to history
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RiwayatPesananScreen()),
              );
            }
          } else if (type == 'topup' || type == 'refund') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DompetDigitalScreen()),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead
                ? AppColors.white
                : AppColors.primaryGreen.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: isRead
                ? null
                : Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            judul,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: isRead
                                  ? FontWeight.w400
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pesan,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (timestamp != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _formatWaktu(timestamp),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWaktu(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';

    final bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${bulan[date.month]} ${date.year}';
  }
}
