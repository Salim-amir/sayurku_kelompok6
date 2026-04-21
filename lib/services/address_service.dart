import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';
import '../core/constants.dart';

class AddressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Reference ke subcollection addresses ──
  CollectionReference _addressCol(String userId) {
    return _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection(AppConstants.subColAddresses);
  }

  // ── Ambil semua alamat milik user ──
  Stream<List<AddressModel>> getAlamatList(String userId) {
    return _addressCol(userId).snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            AddressModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  // ── Tambah alamat baru ──
  Future<String?> tambahAlamat({
    required String userId,
    required AddressModel alamat,
  }) async {
    try {
      // Jika ini alamat pertama, otomatis jadi primary
      final existing = await _addressCol(userId).get();
      final isPrimary = existing.docs.isEmpty;

      final data = alamat.toMap();
      data['isPrimary'] = isPrimary;

      await _addressCol(userId).add(data);
      return null;
    } catch (e) {
      return 'Gagal menambah alamat: ${e.toString()}';
    }
  }

  // ── Update alamat ──
  Future<String?> updateAlamat({
    required String userId,
    required String addressId,
    required AddressModel alamat,
  }) async {
    try {
      await _addressCol(userId).doc(addressId).update(alamat.toMap());
      return null;
    } catch (e) {
      return 'Gagal mengupdate alamat: ${e.toString()}';
    }
  }

  // ── Hapus alamat ──
  Future<String?> hapusAlamat({
    required String userId,
    required String addressId,
  }) async {
    try {
      await _addressCol(userId).doc(addressId).delete();
      return null;
    } catch (e) {
      return 'Gagal menghapus alamat: ${e.toString()}';
    }
  }

  // ── Set alamat utama ──
  Future<String?> setAlamatUtama({
    required String userId,
    required String addressId,
  }) async {
    try {
      // 1. Reset semua alamat jadi non-primary
      final allDocs = await _addressCol(userId).get();
      for (var doc in allDocs.docs) {
        await doc.reference.update({'isPrimary': false});
      }

      // 2. Set yang dipilih jadi primary
      await _addressCol(userId).doc(addressId).update({'isPrimary': true});
      return null;
    } catch (e) {
      return 'Gagal mengatur alamat utama: ${e.toString()}';
    }
  }

  // ── Ambil alamat utama ──
  Future<AddressModel?> getAlamatUtama(String userId) async {
    try {
      final snapshot = await _addressCol(userId)
          .where('isPrimary', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // Fallback ke alamat pertama jika tidak ada primary
        final all = await _addressCol(userId).limit(1).get();
        if (all.docs.isEmpty) return null;
        return AddressModel.fromMap(
            all.docs.first.data() as Map<String, dynamic>,
            all.docs.first.id);
      }

      return AddressModel.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>,
          snapshot.docs.first.id);
    } catch (e) {
      return null;
    }
  }
}
