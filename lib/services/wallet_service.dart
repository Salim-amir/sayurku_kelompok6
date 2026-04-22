import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class WalletService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Ambil saldo wallet user ──
  Future<double> getSaldo(String userId) async {
    final doc = await _db
        .collection(AppConstants.colWallets)
        .doc(userId)
        .get();

    if (doc.exists) {
      return (doc.data()?['saldo'] ?? 0).toDouble();
    }
    return 0;
  }

  // ── Tambah saldo (top up) ──
  Future<void> tambahSaldo({
    required String userId,
    required double jumlah,
  }) async {
    final ref = _db.collection(AppConstants.colWallets).doc(userId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      double saldoSekarang = 0;
      if (snapshot.exists) {
        saldoSekarang = (snapshot.data()?['saldo'] ?? 0).toDouble();
      }

      transaction.set(ref, {
        'saldo': saldoSekarang + jumlah,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ── Kurangi saldo (saat bayar pesanan) ──
  Future<void> kurangiSaldo({
    required String userId,
    required double jumlah,
  }) async {
    final ref = _db.collection(AppConstants.colWallets).doc(userId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      double saldoSekarang = 0;
      if (snapshot.exists) {
        saldoSekarang = (snapshot.data()?['saldo'] ?? 0).toDouble();
      }

      if (saldoSekarang < jumlah) {
        throw Exception("Saldo tidak cukup");
      }

      transaction.update(ref, {
        'saldo': saldoSekarang - jumlah,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ── Stream saldo (real-time) ──
  Stream<double> streamSaldo(String userId) {
    return _db
        .collection(AppConstants.colWallets)
        .doc(userId)
        .snapshots()
        .map((doc) => (doc.data()?['saldo'] ?? 0).toDouble());
  }
}