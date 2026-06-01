import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import 'notification_service.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Buat pesanan baru saat customer checkout ──
  Future<String?> buatPesananBaru({
    required String userId,
    required List<Map<String, dynamic>> items,
    required double totalHarga,
    required double ongkosKirim,
    required String metodePembayaran,
    required String alamatPengiriman,
  }) async {
    try {
      await _db.collection(AppConstants.colOrders).add({
        'userId': userId,
        'items': items,
        'totalHarga': totalHarga,
        'ongkosKirim': ongkosKirim,
        'metodePembayaran': metodePembayaran,
        'alamatPengiriman': alamatPengiriman,
        'status': AppConstants.statusMenunggu,
        'tanggalPesan': FieldValue.serverTimestamp(),
      });

      // --- PELATUK NOTIFIKASI KE ADMIN ---
      try {
        final adminQuery = await _db
            .collection(AppConstants.colUsers)
            .where('role', isEqualTo: 'admin')
            .get();
        for (var doc in adminQuery.docs) {
          final adminToken = doc.data()['fcmToken'];
          if (adminToken != null) {
            await NotificationService.sendPushNotification(
              adminToken,
              'Pesanan Baru Masuk! 🛒',
              'Ada pelanggan yang baru membuat pesanan. Segera cek dashboard!',
            );
          }
        }
      } catch (e) {
        print("Gagal mengirim notif ke admin: $e");
      }
      // -----------------------------------

      return null;
    } catch (e) {
      return 'Gagal membuat pesanan: ${e.toString()}';
    }
  }

  // ── Ambil semua pesanan untuk Admin ──
  Stream<List<Map<String, dynamic>>> getSemuaPesananAdmin() {
    return _db
        .collection(AppConstants.colOrders)
        .orderBy('tanggalPesan', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // ── Alias agar screen yang pakai getAllPesananAdmin() tidak error ──
  Stream<List<Map<String, dynamic>>> getAllPesananAdmin() =>
      getSemuaPesananAdmin();

  // ── Ambil semua pesanan milik customer tertentu ──
  Stream<List<Map<String, dynamic>>> getPesananByUser(String userId) {
    return _db
        .collection(AppConstants.colOrders)
        .where('userId', isEqualTo: userId)
        .orderBy('tanggalPesan', descending: true)
        .snapshots()
        .handleError((error) {
          return;
        })
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // ── Update status pesanan (untuk admin) ──
  Future<String?> updateStatusPesanan({
    required String orderId,
    required String statusBaru,
    String? namaKurir,
    String? noTelpKurir,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': statusBaru,
        'tanggalUpdate': FieldValue.serverTimestamp(),
      };

      if (statusBaru == AppConstants.statusDikirim) {
        updateData['tanggalDikirim'] = FieldValue.serverTimestamp();
      } else if (statusBaru == AppConstants.statusSelesai) {
        updateData['tanggalSelesai'] = FieldValue.serverTimestamp();
      }
      
      if (namaKurir != null && namaKurir.isNotEmpty) {
        updateData['namaKurir'] = namaKurir;
      }
      if (noTelpKurir != null && noTelpKurir.isNotEmpty) {
        updateData['noTelpKurir'] = noTelpKurir;
      }

      await _db.collection(AppConstants.colOrders).doc(orderId).update(updateData);
      // --- MULAILAH MENARIK PELATUK FCM & DATABASE ---
      final orderDoc = await _db
          .collection(AppConstants.colOrders)
          .doc(orderId)
          .get();
      final userId = orderDoc.data()?['userId'];

      if (userId != null) {
        final userDoc = await _db
            .collection(AppConstants.colUsers)
            .doc(userId)
            .get();
        final fcmToken = userDoc.data()?['fcmToken'];

        final title = 'Pesanan SayurKu Diperbarui 🥦';
        final message =
            'Status pesanan kamu sekarang: $statusBaru. Cek aplikasi ya!';

        // 1. Simpan Riwayat ke Database (Agar muncul di NotifikasiScreen)
        await _db.collection(AppConstants.colNotifications).add({
          'userId': userId,
          'title': title,
          'message': message,
          'type': 'order',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 2. Tembak Notifikasi FCM ke Layar HP
        if (fcmToken != null) {
          await NotificationService.sendPushNotification(
            fcmToken,
            title,
            message,
          );
        }
      }
      return null;
    } catch (e) {
      return 'Gagal update status: ${e.toString()}';
    }
  }

  // ── Ambil pesanan berdasarkan status tertentu ──
  Stream<List<Map<String, dynamic>>> getPesananByStatus(
    String userId,
    String status,
  ) {
    return _db
        .collection(AppConstants.colOrders)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('tanggalPesan', descending: true)
        .snapshots()
        .handleError((error) {
          return;
        })
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // ── Ambil detail 1 pesanan ──
  Future<Map<String, dynamic>?> getDetailPesanan(String orderId) async {
    try {
      final doc = await _db
          .collection(AppConstants.colOrders)
          .doc(orderId)
          .get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
