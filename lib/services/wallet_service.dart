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
  /// Flow manual: customer ajukan → admin approve → saldo bertambah
  Future<String?> topUpSaldo({
    required String userId,
    required double amount,
  }) async {
    try {
      if (amount <= 0) return 'Nominal harus lebih dari 0';
      if (amount < 10000) return 'Minimal isi saldo Rp 10.000';

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
        'keterangan': 'Permintaan isi saldo Rp ${_formatNominal(amount.toInt())}',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return null; // Sukses
    } catch (e) {
      return 'Gagal mengajukan top-up: ${e.toString()}';
    }
  }


  // ── Potong saldo saat customer bayar dengan dompet digital ──
  /// Menggunakan Firestore Transaction untuk mencegah race condition
  Future<String?> potongSaldo({
    required String userId,
    required double amount,
    String? orderId,
  }) async {
    try {
      if (amount <= 0) return 'Nominal pembayaran tidak valid';

      await _db.runTransaction((transaction) async {
        // 1. Baca saldo secara atomic
        final userRef = _db.collection(AppConstants.colUsers).doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User tidak ditemukan');
        }

        final currentSaldo = (userDoc.data()?['saldo'] ?? 0).toDouble();

        // 2. Validasi saldo cukup
        if (currentSaldo < amount) {
          throw Exception(
              'Saldo tidak cukup. Saldo Anda: Rp ${_formatNominal(currentSaldo.toInt())}');
        }

        // 3. Kurangi saldo (atomic)
        transaction.update(userRef, {
          'saldo': currentSaldo - amount,
        });

        // 4. Catat transaksi pembayaran
        final txRef = _db
            .collection(AppConstants.colWallets)
            .doc(userId)
            .collection(AppConstants.subColTransactions)
            .doc();

        transaction.set(txRef, {
          'userId': userId,
          'type': AppConstants.txPayment,
          'amount': amount,
          'status': AppConstants.txStatusSuccess,
          'orderId': orderId ?? '',
          'keterangan': 'Pembayaran pesanan',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      return null; // Sukses
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Saldo tidak cukup')) {
        // Ambil pesan error dari exception
        return msg.replaceAll('Exception: ', '');
      }
      return 'Gagal memproses pembayaran: $msg';
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
        .handleError((error) {
      return;
    }).map((snapshot) => snapshot.docs
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
      await _db.runTransaction((transaction) async {
        // 1. Baca data user
        final userRef = _db.collection(AppConstants.colUsers).doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User tidak ditemukan');
        }

        final currentSaldo = (userDoc.data()?['saldo'] ?? 0).toDouble();

        // 2. Update status transaksi
        final txRef = _db
            .collection(AppConstants.colWallets)
            .doc(userId)
            .collection(AppConstants.subColTransactions)
            .doc(transactionId);

        transaction.update(txRef, {
          'status': AppConstants.txStatusApproved,
          'approvedAt': FieldValue.serverTimestamp(),
        });

        // 3. Tambah saldo user (atomic)
        transaction.update(userRef, {
          'saldo': currentSaldo + amount,
        });
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

  // ── Helper format nominal ──
  String _formatNominal(int nominal) {
    return nominal.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
