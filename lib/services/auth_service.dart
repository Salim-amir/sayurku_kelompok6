import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../core/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ─── Model Hasil Login ─────────────────────────────────────────────────────
/// Membawa dua informasi sekaligus:
/// [error] — pesan error jika gagal (null jika sukses)
/// [role]  — role user yang berhasil login ('customer' atau 'admin')
class LoginResult {
  final String? error;
  final String? role;

  LoginResult({this.error, this.role});
}

// ─── Auth Service ──────────────────────────────────────────────────────────
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- FUNGSI LOGIN (dengan role detection) ---
  Future<LoginResult> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login ke Firebase Auth
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Ambil data user dari Firestore untuk cek role
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.colUsers)
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        return LoginResult(error: 'Data akun tidak ditemukan.');
      }

      final data = doc.data() as Map<String, dynamic>;
      final String role = data['role'] ?? AppConstants.roleCustomer;

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _firestore
            .collection(AppConstants.colUsers)
            .doc(credential.user!.uid)
            .update({'fcmToken': fcmToken});
        print("Plat Nomor FCM Token berhasil disimpan!");
      }

      print("Login sukses. Role: $role");

      return LoginResult(role: role);
    } on FirebaseAuthException catch (e) {
      return LoginResult(error: e.message);
    } catch (e) {
      return LoginResult(error: 'Terjadi kesalahan sistem: ${e.toString()}');
    }
  }

  // --- FUNGSI LOGIN GOOGLE ---
  Future<String?> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Login dibatalkan.';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );
      final User? user = result.user;
      if (user == null) return 'Gagal mendapatkan data user.';

      final doc = await _firestore
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await _firestore.collection(AppConstants.colUsers).doc(user.uid).set({
          'uid': user.uid,
          'namaLengkap': user.displayName ?? '',
          'email': user.email ?? '',
          'nomorHp': '',
          'role': AppConstants.roleCustomer,
          'photoUrl': user.photoURL ?? '',
        });
      }
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _firestore.collection(AppConstants.colUsers).doc(user.uid).update(
          {
            'fcmToken': fcmToken,
          },
        );
        print("Plat Nomor FCM Token berhasil disimpan (via Google)!");
      }
      return null;
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
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _firestore
            .collection(AppConstants.colUsers)
            .doc(credential.user!.uid)
            .update({'fcmToken': fcmToken});
        print("Plat Nomor FCM Token berhasil disimpan!");
      }
      print("5. SUKSES SIMPAN KE FIRESTORE!");
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: ${e.toString()}";
    }
  }

  // --- FUNGSI RESET PASSWORD (pakai email langsung) ---
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Link reset password berhasil dikirim ke $email");
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: ${e.toString()}";
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print("Berhasil logout dari Firebase dan Google!");
    } catch (e) {
      print("Error saat logout: ${e.toString()}");
    }
  }

  // --- CEK STATUS LOGIN ---
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
