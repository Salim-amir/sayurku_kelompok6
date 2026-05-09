import 'package:flutter/foundation.dart';

class CartManager {
  static final CartManager instance = CartManager._();
  CartManager._();
  
  final List<Map<String, dynamic>> _items = [];
  final ValueNotifier<int> jumlahNotifier = ValueNotifier(0);
  List<Map<String, dynamic>> get items => _items;

  int get totalProduk => _items.fold(0, (sum, item) => sum + (item['jumlah'] as int));

  int get totalHarga => _items.fold(
      0, (sum, item) => sum + (item['harga'] as int) * (item['jumlah'] as int));

  void tambahProduk(Map<String, dynamic> produk, int jumlah) {
    final index = _items.indexWhere((i) => i['nama'] == produk['nama']);
    if (index != -1) {
      _items[index]['jumlah'] += jumlah;
    } else {
      _items.add({
        'nama': produk['nama'],
        'harga': produk['harga'],
        'satuan': produk['satuan'] ?? '',
        'imageUrl': produk['imageUrl'] ?? '',
        'jumlah': jumlah,
      });
    }
    jumlahNotifier.value = totalProduk; // ← tambah ini
  }

  void hapusProduk(int index) {
    _items.removeAt(index);
    jumlahNotifier.value = totalProduk; // ← tambah ini
  }

  void updateJumlah(int index, int jumlah) {
    if (jumlah <= 0) {
      hapusProduk(index);
    } else {
      _items[index]['jumlah'] = jumlah;
      jumlahNotifier.value = totalProduk; // ← tambah ini
    }
  }

  void kosongkanKeranjang() {
    _items.clear();
    jumlahNotifier.value = 0;
  }
}