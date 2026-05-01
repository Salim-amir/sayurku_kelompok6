import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

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
      return null; // Sukses
    } catch (e) {
      return 'Gagal membuat pesanan: ${e.toString()}';
    }
  }

// ── Ambil semua pesanan untuk Admin (Bypass Index) ──
  Stream<List<Map<String, dynamic>>> getSemuaPesananAdmin() {
    return _db
        .collection(AppConstants.colOrders)
        .orderBy('tanggalPesan', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ── Ambil semua pesanan milik customer tertentu ──
  Stream<List<Map<String, dynamic>>> getPesananByUser(String userId) {
    return _db
        .collection(AppConstants.colOrders)
        .where('userId', isEqualTo: userId)
        .orderBy('tanggalPesan', descending: true)
        .snapshots()
        .handleError((error) {
      // Jika composite index belum dibuat, fallback tanpa orderBy
      // Error FAILED_PRECONDITION berarti index belum ada
      return;
    }).map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ── Update status pesanan (untuk admin) ──
  Future<String?> updateStatusPesanan({
    required String orderId,
    required String statusBaru,
  }) async {
    try {
      await _db.collection(AppConstants.colOrders).doc(orderId).update({
        'status': statusBaru,
        'tanggalUpdate': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Gagal update status: ${e.toString()}';
    }
  }

  // ── Ambil pesanan berdasarkan status tertentu ──
  Stream<List<Map<String, dynamic>>> getPesananByStatus(
      String userId, String status) {
    return _db
        .collection(AppConstants.colOrders)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('tanggalPesan', descending: true)
        .snapshots()
        .handleError((error) {
      return;
    }).map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ── Ambil detail 1 pesanan ──
  Future<Map<String, dynamic>?> getDetailPesanan(String orderId) async {
    try {
      final doc =
          await _db.collection(AppConstants.colOrders).doc(orderId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}