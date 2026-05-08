import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

/// Service untuk mengelola profil pengguna
/// Menangani sinkronisasi data antara Firebase Auth dan Firestore
class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Referensi ke document user ──
  DocumentReference _userDoc(String uid) {
    return _db.collection(AppConstants.colUsers).doc(uid);
  }

  // ── Stream data profil real-time ──
  Stream<UserModel?> getProfilStream(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  // ── Get data profil sekali ──
  Future<UserModel?> getProfilOnce(String uid) async {
    try {
      final doc = await _userDoc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      return null;
    }
  }

  // ── Update nama & nomor HP ke Firestore ──
  Future<String?> updateProfil({
    required String uid,
    required String namaLengkap,
    required String nomorHp,
  }) async {
    try {
      // Validasi
      if (namaLengkap.trim().isEmpty) {
        return 'Nama lengkap tidak boleh kosong';
      }
      if (nomorHp.trim().isEmpty) {
        return 'Nomor HP tidak boleh kosong';
      }

      // Cek apakah nomor HP sudah dipakai user lain
      final cekHp = await _db
          .collection(AppConstants.colUsers)
          .where('nomorHp', isEqualTo: nomorHp.trim())
          .get();

      for (var doc in cekHp.docs) {
        if (doc.id != uid) {
          return 'Nomor HP sudah digunakan oleh akun lain';
        }
      }

      await _userDoc(uid).update({
        'namaLengkap': namaLengkap.trim(),
        'nomorHp': nomorHp.trim(),
      });

      return null; // Sukses
    } catch (e) {
      return 'Gagal memperbarui profil: ${e.toString()}';
    }
  }

  // ── Upload foto profil ke Firebase Storage ──
  /// Menyimpan foto ke Storage dan update URL di Firestore
  Future<String?> uploadFotoProfil({
    required String uid,
    required File imageFile,
  }) async {
    try {
      // 1. Upload ke Firebase Storage
      final ref = _storage.ref().child('profile_photos/$uid.jpg');
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // 2. Dapatkan URL download
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // 3. Update fotoUrl di Firestore
      await _userDoc(uid).update({'fotoUrl': downloadUrl});

      return null; // Sukses
    } catch (e) {
      return 'Gagal upload foto: ${e.toString()}';
    }
  }

  // ── Hapus foto profil ──
  Future<String?> hapusFotoProfil({required String uid}) async {
    try {
      // 1. Hapus dari Storage
      try {
        await _storage.ref().child('profile_photos/$uid.jpg').delete();
      } catch (_) {
        // File mungkin tidak ada, lanjutkan
      }

      // 2. Kosongkan fotoUrl di Firestore
      await _userDoc(uid).update({'fotoUrl': ''});

      return null;
    } catch (e) {
      return 'Gagal menghapus foto: ${e.toString()}';
    }
  }

  // ── Update email (Firebase Auth + Firestore) ──
  /// Memerlukan re-authentication sebelum update email
  Future<String?> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User tidak ditemukan';

      // Validasi format email
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(newEmail.trim())) {
        return 'Format email tidak valid';
      }

      // 1. Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      try {
        await user.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          return 'Password salah. Silakan coba lagi.';
        }
        return 'Gagal verifikasi: ${e.message}';
      }

      // 2. Update email di Firebase Auth
      await user.verifyBeforeUpdateEmail(newEmail.trim());

      // 3. Update email di Firestore
      await _userDoc(user.uid).update({
        'email': newEmail.trim(),
      });

      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email sudah digunakan oleh akun lain';
      }
      return 'Gagal update email: ${e.message}';
    } catch (e) {
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  // ── Ganti password (re-auth + update password) ──
  Future<String?> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User tidak ditemukan';

      // Validasi
      if (passwordBaru.length < 6) {
        return 'Password baru minimal 6 karakter';
      }

      // 1. Re-authenticate dengan password lama
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordLama,
      );

      try {
        await user.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          return 'Password lama salah. Silakan coba lagi.';
        }
        return 'Gagal verifikasi: ${e.message}';
      }

      // 2. Update password baru
      await user.updatePassword(passwordBaru);

      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return 'Gagal mengganti password: ${e.message}';
    } catch (e) {
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  // ── Kirim link reset password via email ──
  Future<String?> kirimResetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return 'Gagal mengirim link reset: ${e.message}';
    } catch (e) {
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }
}
