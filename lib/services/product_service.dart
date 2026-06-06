import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../core/constants.dart';
import 'dart:io';
import 'dart:convert'; // Dibutuhkan untuk enkripsi Base64

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Ambil semua produk yang tersedia (untuk Home & Katalog) ──
  Stream<List<ProductModel>> getSemuaProduk() {
    return _db
        .collection(AppConstants.colProducts)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ── Ambil semua produk (untuk Admin, tanpa filter tersedia) ──
  Stream<List<ProductModel>> getAdminSemuaProduk() {
    return _db
        .collection(AppConstants.colProducts)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ProductModel>> cariProdukByKategori(String keyword, String kategori) {
    return _db
        .collection(AppConstants.colProducts)
        .where('kategori', isEqualTo: kategori)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .where((produk) =>
                produk.nama.toLowerCase().contains(keyword.toLowerCase()))
            .toList());
  }

  // ── Ambil produk berdasarkan kategori (untuk filter Katalog) ──
  Stream<List<ProductModel>> getProdukByKategori(String kategori) {
    return _db
        .collection(AppConstants.colProducts)
        .where('kategori', isEqualTo: kategori)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ── Ambil detail 1 produk (untuk halaman Detail Produk) ──
  Future<ProductModel?> getDetailProduk(String productId) async {
    final doc = await _db
        .collection(AppConstants.colProducts)
        .doc(productId)
        .get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // ── Cari produk berdasarkan nama (untuk Search Bar) ──
  Stream<List<ProductModel>> cariProduk(String keyword) {
    return _db
        .collection(AppConstants.colProducts)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .where((produk) =>
                produk.nama.toLowerCase().contains(keyword.toLowerCase()))
            .toList());
  }

  // 💡 LOGIKA BARU: Mengubah File foto menjadi String Base64 murni
  Future<String> uploadImage(File file) async {
    try {
      final List<int> imageBytes = await file.readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      return base64Image;
    } catch (e) {
      throw Exception('Gagal memproses algoritma Base64: $e');
    }
  }

  // CREATE
  Future<void> addProduct({
    required String nama,
    required int harga,
    required int stok,
    required String kategori,
    required String imageUrl, // Menampung String Teks Base64
    required String satuan,
    required String deskripsi,
  }) async {
    await _db.collection(AppConstants.colProducts).add({
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'kategori': kategori,
      'imageUrl': imageUrl,
      'satuan': satuan,
      'deskripsi': deskripsi,
      'tersedia': true,
      'terjual': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE
  Future<void> updateProduct({
    required String id,
    required String nama,
    required int harga,
    required int stok,
    required String kategori,
    required String imageUrl,
    required String satuan,
    required String deskripsi,
  }) async {
    await _db.collection(AppConstants.colProducts).doc(id).update({
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'kategori': kategori,
      'imageUrl': imageUrl,
      'satuan': satuan,
      'deskripsi': deskripsi,
    });
  }

  // ── UPDATE STOK CEPAT ──
  Future<void> updateStok(String id, int stokBaru) async {
    await _db.collection(AppConstants.colProducts).doc(id).update({
      'stok': stokBaru,
      'tersedia': stokBaru > 0, // Otomatis perbarui ketersediaan
    });
  }

  // DELETE
  Future<void> deleteProduct(String id) async {
    await _db.collection(AppConstants.colProducts).doc(id).delete();
  }
}