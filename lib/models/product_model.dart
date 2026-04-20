class ProductModel {
  final String id;
  final String nama;
  final String kategori;
  final String fotoUrl;
  final double harga;
  final String satuan;
  final int stok;
  final bool tersedia;

  ProductModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.fotoUrl,
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
      fotoUrl: map['fotoUrl'] ?? '',
      harga: (map['harga'] ?? 0).toDouble(),
      satuan: map['satuan'] ?? '',
      stok: map['stok'] ?? 0,
      tersedia: map['tersedia'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'kategori': kategori,
      'fotoUrl': fotoUrl,
      'harga': harga,
      'satuan': satuan,
      'stok': stok,
      'tersedia': tersedia,
    };
  }
}