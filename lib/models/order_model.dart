import '../core/constants.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double totalHarga;
  final double ongkosKirim;
  final String metodePembayaran;
  final String alamatPengiriman;
  final String status;
  final DateTime? tanggalPesan;
  final String? namaKurir;
  final String? noTelpKurir;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalHarga,
    required this.ongkosKirim,
    required this.metodePembayaran,
    required this.alamatPengiriman,
    required this.status,
    this.tanggalPesan,
    this.namaKurir,
    this.noTelpKurir,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalHarga: (map['totalHarga'] ?? 0).toDouble(),
      ongkosKirim: (map['ongkosKirim'] ?? 0).toDouble(),
      metodePembayaran: map['metodePembayaran'] ?? '',
      alamatPengiriman: map['alamatPengiriman'] ?? '',
      status: map['status'] ?? AppConstants.statusMenunggu,
      tanggalPesan: map['tanggalPesan']?.toDate(),
      namaKurir: map['namaKurir'],
      noTelpKurir: map['noTelpKurir'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'totalHarga': totalHarga,
      'ongkosKirim': ongkosKirim,
      'metodePembayaran': metodePembayaran,
      'alamatPengiriman': alamatPengiriman,
      'status': status,
      'tanggalPesan': tanggalPesan,
      'namaKurir': namaKurir,
      'noTelpKurir': noTelpKurir,
    };
  }
}