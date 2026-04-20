import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- FUNGSI REGISTER ---
  // Fungsi ini mengembalikan String (pesan error). Jika sukses, mengembalikan null.
  Future<String?> registerUser({
    required String email,
    required String password,
    required String namaLengkap,
    required String nomorHp,
  }) async {
    try {
      // ─── 1. VALIDASI NOMOR HP GANDA ───
      print("1. Cek apakah Nomor HP sudah terdaftar...");
      QuerySnapshot cekHp = await _firestore
          .collection(AppConstants.colUsers) // Menggunakan variabel constant
          .where('nomorHp', isEqualTo: nomorHp)
          .get();

      if (cekHp.docs.isNotEmpty) {
        // Jika ada data yang cocok, hentikan pendaftaran!
        return "Nomor HP ini sudah terdaftar. Silakan gunakan nomor lain!";
      }

      // ─── 2. DAFTAR KE FIREBASE AUTH ───
      print("2. Mulai daftar ke Auth...");
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("3. Sukses Auth! UID: ${credential.user!.uid}");

      UserModel newUser = UserModel(
        uid: credential.user!.uid,
        namaLengkap: namaLengkap,
        nomorHp: nomorHp,
        email: email,
      );

      // ─── 3. SIMPAN KE FIRESTORE DENGAN ROLE ───
      print("4. Mulai simpan ke Firestore...");
      
      // Kita ubah newUser.toMap() untuk menambahkan role default (Customer)
      Map<String, dynamic> userData = newUser.toMap();
      userData['role'] = AppConstants.roleCustomer; 

      await _firestore
          .collection(AppConstants.colUsers)
          .doc(credential.user!.uid)
          .set(userData);

      print("5. SUKSES SIMPAN KE FIRESTORE!");

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: ${e.toString()}";
    }
  }

  // --- FUNGSI LOGIN ---
  // Sama seperti register, mengembalikan String error jika gagal, dan null jika sukses.
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Perintah bawaan Firebase untuk mengecek kecocokan email & password
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Sukses! Tidak ada pesan error.
    } on FirebaseAuthException catch (e) {
      // Tangkap error dari Firebase (misal: "user-not-found" atau "wrong-password")
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan sistem: ${e.toString()}";
    }
  }
}
