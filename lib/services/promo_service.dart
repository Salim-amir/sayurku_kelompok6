import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promo_model.dart';

class PromoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // READ
  Stream<List<PromoModel>> getPromos() {
    return _db.collection('promos').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => PromoModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // CREATE
  Future<void> addPromo({
    required String title,
    required String subtitle,
    required String imageUrl,
  }) async {
    await _db.collection('promos').add({
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE
  Future<void> updatePromo({
    required String id,
    required String title,
    required String subtitle,
    required String imageUrl,
  }) async {
    await _db.collection('promos').doc(id).update({
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
    });
  }

  // DELETE
  Future<void> deletePromo(String id) async {
    await _db.collection('promos').doc(id).delete();
  }
}