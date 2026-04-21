class ProductModel {
  final String id;
  final String nama;
  final String kategori;
  final String imageUrl;
  final int harga;
  final String satuan;
  final int stok;
  final bool tersedia;

  ProductModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.imageUrl,
    required this.harga,
    required this.satuan,
    required this.stok,
    required this.tersedia,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      nama: map['nama'] ?? '',
      kategori: map['kategori'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      harga: map['harga'] ?? 0,
      satuan: map['satuan'] ?? '',
      stok: map['stok'] ?? 0,
      tersedia: map['tersedia'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'kategori': kategori,
      'imageUrl': imageUrl,
      'harga': harga,
      'satuan': satuan,
      'stok': stok,
      'tersedia': tersedia,
    };
  }
}