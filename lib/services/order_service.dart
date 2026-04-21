import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Buat pesanan baru saat customer checkout ──
  Future<void> buatPesananBaru({
    required String userId,
    required List<Map<String, dynamic>> items,
    required double totalHarga,
    required double ongkosKirim,
    required String metodePembayaran,
    required String alamatPengiriman,
  }) async {
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
  }

  // ── Ambil semua pesanan milik customer tertentu ──
  Stream<List<Map<String, dynamic>>> getPesananByUser(String userId) {
    return _db
        .collection(AppConstants.colOrders)
        .where('userId', isEqualTo: userId)
        .orderBy('tanggalPesan', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

 // ── Update status pesanan (untuk admin) ──
Future<void> updateStatusPesanan({
  required String orderId,
  required String statusBaru,
}) async {
  await _db.collection(AppConstants.colOrders).doc(orderId).update({
    'status': statusBaru,
    'tanggalUpdate': FieldValue.serverTimestamp(),
  });
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
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ── Ambil detail 1 pesanan ──
  Future<Map<String, dynamic>?> getDetailPesanan(String orderId) async {
    final doc =
        await _db.collection(AppConstants.colOrders).doc(orderId).get();
    if (doc.exists) {
      return {'id': doc.id, ...doc.data()!};
    }
    return null;
  }
}