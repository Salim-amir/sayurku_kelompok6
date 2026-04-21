class UserModel {
  final String uid;
  final String namaLengkap;
  final String nomorHp;
  final String email;
  final String role; // 'customer' atau 'admin'
  final String alamat;
  final String fotoUrl;
  final double saldo; // Saldo dompet digital

  UserModel({
    required this.uid,
    required this.namaLengkap,
    required this.nomorHp,
    required this.email,
    this.role = 'customer',
    this.alamat = '',
    this.fotoUrl = '',
    this.saldo = 0,
  });

  // Dari Firestore → Dart Object
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      namaLengkap: map['namaLengkap'] ?? '',
      nomorHp: map['nomorHp'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      alamat: map['alamat'] ?? '',
      fotoUrl: map['fotoUrl'] ?? '',
      saldo: (map['saldo'] ?? 0).toDouble(),
    );
  }

  // Dart Object → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'namaLengkap': namaLengkap,
      'nomorHp': nomorHp,
      'email': email,
      'role': role,
      'alamat': alamat,
      'fotoUrl': fotoUrl,
      'saldo': saldo,
    };
  }
}