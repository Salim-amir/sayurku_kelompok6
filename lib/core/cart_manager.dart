class CartManager {
  CartManager._();
  static final CartManager instance = CartManager._();

  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  int get totalProduk => _items.length;

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
        'jumlah': jumlah,
      });
    }
  }

  void hapusProduk(int index) {
    _items.removeAt(index);
  }

  void updateJumlah(int index, int jumlah) {
    if (jumlah <= 0) {
      hapusProduk(index);
    } else {
      _items[index]['jumlah'] = jumlah;
    }
  }
}