import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Methods
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<UserModel> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Place Methods
  Future<String> addPlace(PlaceModel place) async {
    try {
      print('FirestoreService: Starting to add place ${place.title}');
      final docRef = await _firestore.collection('places').add(place.toMap());
      print('FirestoreService: Place added with ID ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('FirestoreService: Error adding place: $e');
      throw Exception('Failed to add place: $e');
    }
  }

  Stream<List<PlaceModel>> getUserPlaces(String userId) {
    print('FirestoreService: Getting places for user $userId');
    return _firestore
        .collection('places')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('FirestoreService: Received ${snapshot.docs.length} places');
          return snapshot.docs
              .map((doc) => PlaceModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> updatePlace(PlaceModel place) async {
    try {
      await _firestore
          .collection('places')
          .doc(place.id)
          .update(place.toMap());
    } catch (e) {
      throw Exception('Failed to update place: $e');
    }
  }

  Future<void> deletePlace(String placeId) async {
    try {
      await _firestore.collection('places').doc(placeId).delete();
    } catch (e) {
      throw Exception('Failed to delete place: $e');
    }
  }
}
