import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import 'notification_service.dart';

class WalletService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Stream saldo real-time dari users/{uid} ──
  Stream<double> getSaldo(String userId) {
    return _db.collection(AppConstants.colUsers).doc(userId).snapshots().map((
      doc,
    ) {
      final data = doc.data();
      if (data == null) return 0.0;
      return (data['saldo'] ?? 0).toDouble();
    });
  }

  // ── Ajukan top-up (status: pending, admin akan validasi) ──
  Future<String?> topUpSaldo({
    required String userId,
    required double amount,
    String? buktiTransferBase64,
  }) async {
    try {
      if (amount <= 0) return 'Nominal harus lebih dari 0';
      if (amount < 10000) return 'Minimal isi saldo Rp 10.000';

      await _db
          .collection(AppConstants.colWallets)
          .doc(userId)
          .collection(AppConstants.subColTransactions)
          .add({
            'userId': userId,
            'type': AppConstants.txTopUp,
            'amount': amount,
            'status': AppConstants.txStatusPending,
            'buktiTransfer': buktiTransferBase64 ?? '',
            'keterangan':
                'Permintaan isi saldo Rp ${_formatNominal(amount.toInt())}',
            'timestamp': FieldValue.serverTimestamp(),
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
              'Top Up Saldo Baru! 💰',
              'Pelanggan mengajukan isi saldo sebesar Rp ${_formatNominal(amount.toInt())}. Segera verifikasi!',
            );
          }
        }
      } catch (e) {
        print("Gagal mengirim notif ke admin: $e");
      }
      // -----------------------------------

      return null;
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
      if (amount <= 0) return 'Nominal pembayaran tidak valid';

      await _db.runTransaction((transaction) async {
        final userRef = _db.collection(AppConstants.colUsers).doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) throw Exception('User tidak ditemukan');

        final currentSaldo = (userDoc.data()?['saldo'] ?? 0).toDouble();
        if (currentSaldo < amount) {
          throw Exception(
            'Saldo tidak cukup. Saldo Anda: Rp ${_formatNominal(currentSaldo.toInt())}',
          );
        }

        transaction.update(userRef, {'saldo': currentSaldo - amount});

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

      return null;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Saldo tidak cukup')) {
        return msg.replaceAll('Exception: ', '');
      }
      return 'Gagal memproses pembayaran: $msg';
    }
  }

  // ── Ambil riwayat transaksi dompet milik 1 customer ──
  Stream<List<Map<String, dynamic>>> getRiwayatTransaksi(String userId) {
    return _db
        .collection(AppConstants.colWallets)
        .doc(userId)
        .collection(AppConstants.subColTransactions)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) => null)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // ── Stream semua top-up untuk admin (REAKTIF INSTAN) ──────────────────────
  /// Menggunakan collectionGroup agar satu listener menangkap perubahan
  /// di SEMUA subcollection transactions/{userId}/transactions sekaligus.
  /// Saat admin approve/reject, status langsung berubah tanpa delay.
  ///
  /// PENTING: Daftarkan collectionGroup index di Firebase Console:
  ///   Collection: transactions | Field: type ASC, timestamp DESC
  Stream<List<Map<String, dynamic>>> getSemuaTopUpAdmin() {
    return _db
        .collectionGroup(AppConstants.subColTransactions)
        .where('type', isEqualTo: AppConstants.txTopUp)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            // Sertakan docPath agar detail screen bisa langsung akses dokumen
            return {'id': doc.id, 'docPath': doc.reference.path, ...(doc.data() as Map<String, dynamic>)};
          }).toList(),
        );
  }

  // ── Approve top-up (dipanggil admin) ─────────────────────────────────────
  Future<String?> approveTopUp({
    required String userId,
    required String transactionId,
    required double amount,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection(AppConstants.colUsers).doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) throw Exception('User tidak ditemukan');

        final currentSaldo = (userDoc.data()?['saldo'] ?? 0).toDouble();
        final txRef = _db
            .collection(AppConstants.colWallets)
            .doc(userId)
            .collection(AppConstants.subColTransactions)
            .doc(transactionId);

        transaction.update(txRef, {
          'status': AppConstants.txStatusApproved,
          'approvedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(userRef, {'saldo': currentSaldo + amount});
      });

      // --- PELATUK NOTIFIKASI KE CUSTOMER ---
      try {
        final userDocForNotif = await _db
            .collection(AppConstants.colUsers)
            .doc(userId)
            .get();
        final fcmToken = userDocForNotif.data()?['fcmToken'];

        final title = 'Top Up Berhasil! 🎉';
        final message =
            'Saldo sebesar Rp ${_formatNominal(amount.toInt())} telah masuk ke dompetmu.';

        // 1. Simpan Riwayat ke Database
        await _db.collection(AppConstants.colNotifications).add({
          'userId': userId,
          'title': title,
          'message': message,
          'type': 'topup',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 2. Tembak Notifikasi FCM
        if (fcmToken != null) {
          await NotificationService.sendPushNotification(
            fcmToken,
            title,
            message,
          );
        }
      } catch (e) {
        print("Gagal kirim notif: $e");
      }
      // --------------------------------------

      return null;
    } catch (e) {
      return 'Gagal approve top-up: ${e.toString()}';
    }
  }

  // ── Reject top-up (dipanggil admin) ──────────────────────────────────────
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

      // --- PELATUK NOTIFIKASI KE CUSTOMER ---
      try {
        final userDocForNotif = await _db
            .collection(AppConstants.colUsers)
            .doc(userId)
            .get();
        final fcmToken = userDocForNotif.data()?['fcmToken'];

        final title = 'Top Up Ditolak ❌';
        final message =
            'Maaf, pengajuan top up kamu ditolak. Pastikan bukti transfer sudah benar.';

        // 1. Simpan Riwayat ke Database
        await _db.collection(AppConstants.colNotifications).add({
          'userId': userId,
          'title': title,
          'message': message,
          'type': 'topup',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 2. Tembak Notifikasi FCM
        if (fcmToken != null) {
          await NotificationService.sendPushNotification(
            fcmToken,
            title,
            message,
          );
        }
      } catch (e) {
        print("Gagal kirim notif: $e");
      }
      // --------------------------------------

      return null;
    } catch (e) {
      return 'Gagal reject top-up: ${e.toString()}';
    }
  }

  // ── Refund saldo saat pesanan dibatalkan (Dompet Digital) ──
  Future<String?> refundSaldo({
    required String userId,
    required double amount,
    String? orderId,
  }) async {
    try {
      if (amount <= 0) return 'Nominal refund tidak valid';

      await _db.runTransaction((transaction) async {
        final userRef = _db.collection(AppConstants.colUsers).doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) throw Exception('User tidak ditemukan');

        final currentSaldo = (userDoc.data()?['saldo'] ?? 0).toDouble();

        // Tambah saldo kembali
        transaction.update(userRef, {'saldo': currentSaldo + amount});

        // Catat transaksi refund
        final txRef = _db
            .collection(AppConstants.colWallets)
            .doc(userId)
            .collection(AppConstants.subColTransactions)
            .doc();

        transaction.set(txRef, {
          'userId': userId,
          'type': 'refund',
          'amount': amount,
          'status': AppConstants.txStatusSuccess,
          'orderId': orderId ?? '',
          'keterangan': 'Refund pesanan dibatalkan',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      // Kirim notifikasi ke customer
      try {
        final userDocForNotif = await _db
            .collection(AppConstants.colUsers)
            .doc(userId)
            .get();
        final fcmToken = userDocForNotif.data()?['fcmToken'];

        final title = 'Refund Berhasil! 💰';
        final message =
            'Saldo sebesar Rp ${_formatNominal(amount.toInt())} telah dikembalikan ke dompet Anda.';

        await _db.collection(AppConstants.colNotifications).add({
          'userId': userId,
          'title': title,
          'message': message,
          'type': 'refund',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (fcmToken != null) {
          await NotificationService.sendPushNotification(
            fcmToken,
            title,
            message,
          );
        }
      } catch (e) {
        print("Gagal kirim notif refund: $e");
      }

      return null;
    } catch (e) {
      return 'Gagal proses refund: ${e.toString()}';
    }
  }

  // ── Helper format nominal ──
  String _formatNominal(int nominal) {
    return nominal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
