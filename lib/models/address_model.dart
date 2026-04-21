class AddressModel {
  final String id;
  final String label;          // "Rumah", "Kantor", dll
  final String namaPenerima;
  final String nomorHp;
  final String alamatLengkap;
  final String kecamatan;
  final String kota;
  final String kodePos;
  final bool isPrimary;

  AddressModel({
    required this.id,
    required this.label,
    required this.namaPenerima,
    required this.nomorHp,
    required this.alamatLengkap,
    this.kecamatan = '',
    this.kota = '',
    this.kodePos = '',
    this.isPrimary = false,
  });

  // Dari Firestore → Dart Object
  factory AddressModel.fromMap(Map<String, dynamic> map, String id) {
    return AddressModel(
      id: id,
      label: map['label'] ?? '',
      namaPenerima: map['namaPenerima'] ?? '',
      nomorHp: map['nomorHp'] ?? '',
      alamatLengkap: map['alamatLengkap'] ?? '',
      kecamatan: map['kecamatan'] ?? '',
      kota: map['kota'] ?? '',
      kodePos: map['kodePos'] ?? '',
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  // Dart Object → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'namaPenerima': namaPenerima,
      'nomorHp': nomorHp,
      'alamatLengkap': alamatLengkap,
      'kecamatan': kecamatan,
      'kota': kota,
      'kodePos': kodePos,
      'isPrimary': isPrimary,
    };
  }

  // Untuk mendapatkan alamat lengkap dalam satu string
  String get fullAddress {
    final parts = <String>[];
    if (alamatLengkap.isNotEmpty) parts.add(alamatLengkap);
    if (kecamatan.isNotEmpty) parts.add(kecamatan);
    if (kota.isNotEmpty) parts.add(kota);
    if (kodePos.isNotEmpty) parts.add(kodePos);
    return parts.join(', ');
  }
}
