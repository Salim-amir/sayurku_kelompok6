import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Import cetakan yang baru kita buat

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
      print("1. Mulai daftar ke Auth...");
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("2. Sukses Auth! UID: ${credential.user!.uid}");

      UserModel newUser = UserModel(
        uid: credential.user!.uid,
        namaLengkap: namaLengkap,
        nomorHp: nomorHp,
        email: email,
      );

      print("3. Mulai simpan ke Firestore...");
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toMap());

      print("4. SUKSES SIMPAN KE FIRESTORE!");

      return null;
    } on FirebaseAuthException catch (e) {
      // Tangkap error spesifik dari Firebase (misal: email sudah dipakai, password kelemahan)
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
