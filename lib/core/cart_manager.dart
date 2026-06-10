import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartManager {
  static final CartManager instance = CartManager._();
  CartManager._();
  
  final List<Map<String, dynamic>> _items = [];
  final ValueNotifier<int> jumlahNotifier = ValueNotifier(0);
  List<Map<String, dynamic>> get items => _items;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartData = prefs.getString('sayurku_cart');
      if (cartData != null) {
        final List<dynamic> decoded = jsonDecode(cartData);
        _items.clear();
        for (var item in decoded) {
          _items.add(Map<String, dynamic>.from(item));
        }
        jumlahNotifier.value = totalProduk;
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sayurku_cart', jsonEncode(_items));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  int get totalProduk => _items.fold(0, (sum, item) => sum + (item['jumlah'] as int));

  int get totalHarga => _items.fold(
      0, (sum, item) => sum + (item['harga'] as int) * (item['jumlah'] as int));

  bool tambahProduk(Map<String, dynamic> produk, int jumlah) {
    final stok = produk['stok'] ?? 999;
    final index = _items.indexWhere((i) => i['nama'] == produk['nama']);
    if (index != -1) {
      // Selalu update data produk terbaru (stok, harga, dll)
      _items[index]['stok'] = stok;
      if (produk.containsKey('harga')) _items[index]['harga'] = produk['harga'];
      if (produk.containsKey('imageUrl')) _items[index]['imageUrl'] = produk['imageUrl'];
      if (produk.containsKey('satuan')) _items[index]['satuan'] = produk['satuan'];
      if (produk.containsKey('id')) _items[index]['id'] = produk['id'];
      if (produk.containsKey('deskripsi')) _items[index]['deskripsi'] = produk['deskripsi'];

      if (_items[index]['jumlah'] + jumlah > stok) {
        if (_items[index]['jumlah'] < stok) {
          _items[index]['jumlah'] = stok;
          jumlahNotifier.value = totalProduk;
        }
        return false; // Stok tidak cukup / sudah batas maksimal
      }
      _items[index]['jumlah'] += jumlah;
    } else {
      if (jumlah > stok) return false; // Stok tidak cukup
      _items.add({
        'nama': produk['nama'],
        'harga': produk['harga'],
        'satuan': produk['satuan'] ?? '',
        'imageUrl': produk['imageUrl'] ?? '',
        'deskripsi': produk['deskripsi'] ?? '',
        'stok': stok,
        'jumlah': jumlah,
      });
    }
    jumlahNotifier.value = totalProduk;
    _saveCart();
    return true;
  }

  void hapusProduk(int index) {
    _items.removeAt(index);
    jumlahNotifier.value = totalProduk;
    _saveCart();
  }

  void updateJumlah(int index, int jumlah) {
    if (jumlah <= 0) {
      hapusProduk(index);
    } else {
      _items[index]['jumlah'] = jumlah;
      jumlahNotifier.value = totalProduk;
      _saveCart();
    }
  }

  void kosongkanKeranjang() {
    _items.clear();
    jumlahNotifier.value = 0;
    _saveCart();
  }
}