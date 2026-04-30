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
      harga: (map['harga'] ?? 0).toInt(),
      satuan: map['satuan'] ?? 'kg',
      stok: (map['stok'] ?? 0).toInt(),
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

  ProductModel copyWith({
    String? id,
    String? nama,
    String? kategori,
    String? imageUrl,
    int? harga,
    String? satuan,
    int? stok,
    bool? tersedia,
  }) {
    return ProductModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      imageUrl: imageUrl ?? this.imageUrl,
      harga: harga ?? this.harga,
      satuan: satuan ?? this.satuan,
      stok: stok ?? this.stok,
      tersedia: tersedia ?? this.tersedia,
    );
  }
}