class ProductModel {
  final String id;
  final String nama;
  final int harga;
  final int stok;
  final String kategori;
  final String imageUrl;
  final bool tersedia;

  ProductModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.kategori,
    required this.imageUrl,
    required this.tersedia,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      nama: data['nama'] ?? '',
      harga: data['harga'] ?? 0,
      stok: data['stok'] ?? 0,
      kategori: data['kategori'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      tersedia: data['tersedia'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'kategori': kategori,
      'imageUrl': imageUrl,
      'tersedia': tersedia,
    };
  }
}