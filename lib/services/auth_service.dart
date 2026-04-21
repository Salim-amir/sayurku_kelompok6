import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      // 1. Buka popup pilih akun Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Login dibatalkan.'; // User cancel popup

      // 2. Ambil token autentikasi
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Buat credential untuk Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Login ke Firebase pakai credential Google
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );
      final User? user = result.user;
      if (user == null) return 'Gagal mendapatkan data user.';

      // 5. Cek apakah user sudah pernah daftar di Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();

      // 6. Kalau belum ada, simpan data baru ke Firestore
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'namaLengkap': user.displayName ?? '',
          'email': user.email ?? '',
          'nomorHp': '', // Nomor HP kosong karena dari Google
          'role': 'customer', // Default role
        });
      }
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }

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
// --- FUNGSI RESET PASSWORD (VERSI EMAIL - FINAL) ---
  Future<String?> resetPassword({required String email}) async {
    try {
      // Langsung tembak emailnya ke Firebase Auth
      await _auth.sendPasswordResetEmail(email: email);
      print("Link reset password berhasil dikirim ke $email");
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: ${e.toString()}";
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logoutUser() async {
    try {
      // 1. Putuskan sesi dari Firebase Auth
      await _auth.signOut();

      // 2. Putuskan SESI DARI GOOGLE SIGN-IN (Ini rahasianya!)
      await _googleSignIn.signOut();

      print("Berhasil Logout dari Firebase dan Google!");
    } catch (e) {
      print("Error saat logout: ${e.toString()}");
    }
  }

  // --- CEK STATUS LOGIN ---
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
