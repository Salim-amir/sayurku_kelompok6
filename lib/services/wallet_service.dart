import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class WalletService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Stream saldo real-time dari users/{uid} ──
  Stream<double> getSaldo(String userId) {
    return _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return 0.0;
      return (data['saldo'] ?? 0).toDouble();
    });
  }

  // ── Ajukan top-up (status: pending, admin akan validasi) ──
  Future<String?> topUpSaldo({
    required String userId,
    required double amount,
  }) async {
    try {
      // Simpan transaksi ke subcollection wallets/{uid}/transactions
      await _db
          .collection(AppConstants.colWallets)
          .doc(userId)
          .collection(AppConstants.subColTransactions)
          .add({
        'userId': userId,
        'type': AppConstants.txTopUp,
        'amount': amount,
        'status': AppConstants.txStatusPending,
        'keterangan': 'Permintaan isi saldo Rp ${amount.toInt()}',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return null; // Sukses
    } catch (e) {
      return 'Gagal mengajukan top-up: ${e.toString()}';
    }
  }

  // ── Potong saldo saat customer bayar dengan dompet digital ──
  Future<String?> potongSaldo({
    required String userId,
    required double amount,
    String? orderId,
  }) async {
    try {
      // 1. Cek saldo cukup
      final userDoc =
          await _db.collection(AppConstants.colUsers).doc(userId).get();
      final currentSaldo = (userDoc.data()?['saldo'] ?? 0).toDouble();

      if (currentSaldo < amount) {
        return 'Saldo tidak cukup. Saldo Anda: Rp ${currentSaldo.toInt()}';
      }

      // 2. Kurangi saldo di users/{uid}
      await _db.collection(AppConstants.colUsers).doc(userId).update({
        'saldo': FieldValue.increment(-amount),
      });

      // 3. Catat transaksi pembayaran
      await _db
          .collection(AppConstants.colWallets)
          .doc(userId)
          .collection(AppConstants.subColTransactions)
          .add({
        'userId': userId,
        'type': AppConstants.txPayment,
        'amount': amount,
        'status': AppConstants.txStatusSuccess,
        'orderId': orderId ?? '',
        'keterangan': 'Pembayaran pesanan',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return null; // Sukses
    } catch (e) {
      return 'Gagal memproses pembayaran: ${e.toString()}';
    }
  }

  // ── Ambil riwayat transaksi dompet ──
  Stream<List<Map<String, dynamic>>> getRiwayatTransaksi(String userId) {
    return _db
        .collection(AppConstants.colWallets)
        .doc(userId)
        .collection(AppConstants.subColTransactions)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ── Approve top-up (dipanggil admin) — tambah saldo ──
  Future<String?> approveTopUp({
    required String userId,
    required String transactionId,
    required double amount,
  }) async {
    try {
      // 1. Update status transaksi
      await _db
          .collection(AppConstants.colWallets)
          .doc(userId)
          .collection(AppConstants.subColTransactions)
          .doc(transactionId)
          .update({
        'status': AppConstants.txStatusApproved,
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // 2. Tambah saldo user
      await _db.collection(AppConstants.colUsers).doc(userId).update({
        'saldo': FieldValue.increment(amount),
      });

      return null;
    } catch (e) {
      return 'Gagal approve top-up: ${e.toString()}';
    }
  }

  // ── Reject top-up (dipanggil admin) ──
  Future<String?> rejectTopUp({
    required String userId,
    required String transactionId,
  }) async {
    try {
      await _db
          .collection(AppConstants.colWallets)
          .doc(userId)
          .collection(AppConstants.subColTransactions)
          .doc(transactionId)
          .update({
        'status': AppConstants.txStatusRejected,
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Gagal reject top-up: ${e.toString()}';
    }
  }
}
