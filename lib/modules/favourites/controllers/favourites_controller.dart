import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class FavouritesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getTemplesStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.empty();

    return _firestore
        .collection('userFavorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .switchMap((favoritesSnapshot) {
      List<String> templeIds = favoritesSnapshot.docs
          .map((doc) => doc['templeId'] as String)
          .toList();

      if (templeIds.isEmpty) return Stream<QuerySnapshot>.empty();

      return _firestore
          .collection('temples')
          .where(FieldPath.documentId, whereIn: templeIds)
          .snapshots();
    });
  }
}