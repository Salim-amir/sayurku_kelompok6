import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import 'notification_service.dart';
import 'wallet_service.dart';

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

      // --- PENGURANGAN STOK PRODUK ---
      for (var item in items) {
        try {
          String? productId = item['id'];
          String? productName = item['nama'];
          int qty = item['jumlah'] ?? 0;

          if (qty > 0) {
            if (productId != null && productId.isNotEmpty) {
              // Jika punya ID, langsung update
              final docRef = _db.collection(AppConstants.colProducts).doc(productId);
              final docSnap = await docRef.get();
              if (docSnap.exists) {
                int stokSekarang = docSnap.data()?['stok'] ?? 0;
                int terjualSekarang = docSnap.data()?['terjual'] ?? 0;
                await docRef.update({
                  'stok': (stokSekarang - qty < 0) ? 0 : stokSekarang - qty,
                  'terjual': terjualSekarang + qty
                });
              }
            } else if (productName != null && productName.isNotEmpty) {
              // Fallback: cari berdasarkan nama jika keranjang lama belum ada ID
              final query = await _db.collection(AppConstants.colProducts).where('nama', isEqualTo: productName).limit(1).get();
              if (query.docs.isNotEmpty) {
                final doc = query.docs.first;
                int stokSekarang = doc.data()['stok'] ?? 0;
                int terjualSekarang = doc.data()['terjual'] ?? 0;
                await doc.reference.update({
                  'stok': (stokSekarang - qty < 0) ? 0 : stokSekarang - qty,
                  'terjual': terjualSekarang + qty
                });
              }
            }
          }
        } catch (e) {
          print("Gagal mengurangi stok produk: $e");
        }
      }
      // -------------------------------

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
              .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
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

      if (statusBaru == AppConstants.statusDiproses) {
        updateData['tanggalDiproses'] = FieldValue.serverTimestamp();
      } else if (statusBaru == AppConstants.statusDikirim) {
        updateData['tanggalDikirim'] = FieldValue.serverTimestamp();
      } else if (statusBaru == AppConstants.statusSelesai) {
        updateData['tanggalSelesai'] = FieldValue.serverTimestamp();
      } else if (statusBaru == AppConstants.statusDibatalkan) {
        updateData['tanggalDibatalkan'] = FieldValue.serverTimestamp();
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

      // --- PENGEMBALIAN STOK JIKA DIBATALKAN ---
      if (statusBaru.toLowerCase() == 'dibatalkan') {
        final items = orderDoc.data()?['items'] as List<dynamic>?;
        if (items != null) {
          for (var item in items) {
            try {
              String? productId = item['id'];
              String? productName = item['nama'];
              int qty = item['jumlah'] ?? 0;

              if (qty > 0) {
                if (productId != null && productId.isNotEmpty) {
                  final docRef = _db.collection(AppConstants.colProducts).doc(productId);
                  final docSnap = await docRef.get();
                  if (docSnap.exists) {
                    int stokSekarang = docSnap.data()?['stok'] ?? 0;
                    int terjualSekarang = docSnap.data()?['terjual'] ?? 0;
                    await docRef.update({
                      'stok': stokSekarang + qty,
                      'terjual': (terjualSekarang - qty < 0) ? 0 : terjualSekarang - qty
                    });
                  }
                } else if (productName != null && productName.isNotEmpty) {
                  final query = await _db.collection(AppConstants.colProducts).where('nama', isEqualTo: productName).limit(1).get();
                  if (query.docs.isNotEmpty) {
                    final doc = query.docs.first;
                    int stokSekarang = doc.data()['stok'] ?? 0;
                    int terjualSekarang = doc.data()['terjual'] ?? 0;
                    await doc.reference.update({
                      'stok': stokSekarang + qty,
                      'terjual': (terjualSekarang - qty < 0) ? 0 : terjualSekarang - qty
                    });
                  }
                }
              }
            } catch (e) {
              print("Gagal mengembalikan stok produk: $e");
            }
          }
        }
      }
      // -----------------------------------------

      // --- REFUND SALDO JIKA BAYAR PAKAI DOMPET DIGITAL ---
      if (statusBaru == AppConstants.statusDibatalkan) {
        final metodePembayaran = orderDoc.data()?['metodePembayaran'] ?? '';
        print("🔍 [REFUND] Status: Dibatalkan, Metode: '$metodePembayaran', UserId: $userId");
        
        if (metodePembayaran == AppConstants.metodeDompet && userId != null) {
          try {
            final totalHarga = (orderDoc.data()?['totalHarga'] ?? 0).toDouble();
            print("🔍 [REFUND] Total yang akan di-refund: Rp $totalHarga");
            
            if (totalHarga > 0) {
              final walletService = WalletService();
              final refundError = await walletService.refundSaldo(
                userId: userId,
                amount: totalHarga,
                orderId: orderId,
              );
              
              if (refundError != null) {
                print("❌ [REFUND] Gagal: $refundError");
              } else {
                print("✅ [REFUND] Berhasil! Saldo Rp $totalHarga dikembalikan ke $userId");
              }
              
              // Tandai pesanan sudah di-refund
              await _db.collection(AppConstants.colOrders).doc(orderId).update({
                'refundStatus': 'selesai',
                'refundMetode': 'saldo',
                'tanggalRefund': FieldValue.serverTimestamp(),
              });
            } else {
              print("⚠️ [REFUND] totalHarga = 0, skip refund");
            }
          } catch (e) {
            print("❌ [REFUND] Exception: $e");
          }
        } else {
          print("ℹ️ [REFUND] Bukan Dompet Digital atau userId null, skip refund");
        }
      }
      // -------------------------------------------------

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

  // ── Update Data Kurir (Tanpa mengubah status) ──
  Future<String?> updateKurirPesanan({
    required String orderId,
    required String namaKurir,
    required String noTelpKurir,
  }) async {
    try {
      await _db.collection(AppConstants.colOrders).doc(orderId).update({
        'namaKurir': namaKurir,
        'noTelpKurir': noTelpKurir,
        'tanggalUpdate': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Gagal update data kurir: ${e.toString()}';
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

  // ── Ambil detail 1 pesanan (Real-time Stream) ──
  Stream<Map<String, dynamic>?> streamDetailPesanan(String orderId) {
    return _db.collection(AppConstants.colOrders).doc(orderId).snapshots().map((doc) {
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    });
  }
}
