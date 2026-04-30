import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../core/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Ambil semua produk yang tersedia (untuk Home & Katalog) ──
  Stream<List<ProductModel>> getSemuaProduk() {
    return _db
        .collection(AppConstants.colProducts)
        .where('tersedia', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ── Ambil produk berdasarkan kategori (untuk filter Katalog) ──
  Stream<List<ProductModel>> getProdukByKategori(String kategori) {
    return _db
        .collection(AppConstants.colProducts)
        .where('tersedia', isEqualTo: true)
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
        .where('tersedia', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .where((produk) =>
                produk.nama.toLowerCase().contains(keyword.toLowerCase()))
            .toList());

  
  }

  // 📸 UPLOAD IMAGE
Future<String> uploadImage(File file) async {
  try {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance
        .ref()
        .child('products')
        .child('$fileName.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  } catch (e) {
    throw Exception('Gagal upload gambar: $e');
  }
}
 // CREATE
Future<void> addProduct({
  required String nama,
  required int harga,
  required int stok,
  required String kategori,
  required String imageUrl,
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

// DELETE
Future<void> deleteProduct(String id) async {
  await _db.collection(AppConstants.colProducts).doc(id).delete();
}
}
