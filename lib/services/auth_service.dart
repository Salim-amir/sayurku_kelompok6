import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- FUNGSI REGISTER ---
  Future<String?> registerUser({
    required String email,
    required String password,
    required String namaLengkap,
    required String nomorHp,
  }) async {
    try {
      print("1. Cek apakah Nomor HP sudah terdaftar...");
      QuerySnapshot cekHp = await _firestore
          .collection(AppConstants.colUsers)
          .where('nomorHp', isEqualTo: nomorHp)
          .get();

      if (cekHp.docs.isNotEmpty) {
        return "Nomor HP ini sudah terdaftar. Silakan gunakan nomor lain!";
      }

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

      print("4. Mulai simpan ke Firestore...");
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
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan sistem: ${e.toString()}";
    }
  }

  // --- FUNGSI RESET PASSWORD ---
  /// Mencari email yang terdaftar berdasarkan nomor HP di Firestore,
  /// lalu mengirim link reset password ke email tersebut via Firebase Auth.
  ///
  /// Mengembalikan [null] jika berhasil.
  /// Mengembalikan [String] pesan error jika gagal.
  Future<String?> resetPassword({required String nomorHp}) async {
    try {
      // ─── 1. CARI EMAIL BERDASARKAN NOMOR HP ───
      print("1. Mencari akun dengan nomor HP: $nomorHp");
      QuerySnapshot hasil = await _firestore
          .collection(AppConstants.colUsers)
          .where('nomorHp', isEqualTo: nomorHp)
          .limit(1)
          .get();

      // Jika tidak ada akun dengan nomor HP tersebut
      if (hasil.docs.isEmpty) {
        return "Nomor HP tidak terdaftar. Periksa kembali nomor Anda.";
      }

      // ─── 2. AMBIL EMAIL DARI DOKUMEN YANG DITEMUKAN ───
      final data = hasil.docs.first.data() as Map<String, dynamic>;
      final String email = data['email'] ?? '';

      if (email.isEmpty) {
        return "Akun ditemukan namun email tidak valid. Hubungi admin.";
      }

      print("2. Email ditemukan: $email — mengirim link reset...");

      // ─── 3. KIRIM LINK RESET KE EMAIL ───
      await _auth.sendPasswordResetEmail(email: email);

      print("3. Link reset password berhasil dikirim ke $email");
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: ${e.toString()}";
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // --- CEK STATUS LOGIN ---
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}