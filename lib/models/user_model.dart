class UserModel {
  final String uid;
  final String namaLengkap;
  final String nomorHp;
  final String email;
  final String role; // Untuk membedakan 'customer' dan 'admin' (pengepul)

  UserModel({
    required this.uid,
    required this.namaLengkap,
    required this.nomorHp,
    required this.email,
    this.role = 'customer', // Otomatis jadi pembeli saat daftar dari aplikasi
  });

  // Fungsi untuk mengubah objek Dart menjadi Map (JSON) agar bisa masuk ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'namaLengkap': namaLengkap,
      'nomorHp': nomorHp,
      'email': email,
      'role': role,
    };
  }
}