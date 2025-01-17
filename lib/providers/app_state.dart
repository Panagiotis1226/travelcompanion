import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/user_model.dart';
import '../models/place_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/map_service.dart';

class AppState with ChangeNotifier {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  final MapService _mapService = MapService();
  
  User? _currentUser;
  UserModel? _userProfile;
  List<PlaceModel> _places = [];
  bool _isLoading = false;
  StreamSubscription? _placesSubscription;

  User? get currentUser => _currentUser;
  UserModel? get userProfile => _userProfile;
  List<PlaceModel> get places => _places;
  bool get isLoading => _isLoading;

  AppState() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges.listen((User? user) async {
      _currentUser = user;
      if (user != null) {
        await _loadUserProfile(user.uid);
        _subscribeToUserPlaces(user.uid);
      } else {
        _unsubscribeFromStreams();
        _userProfile = null;
        _places = [];
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      _userProfile = await _firestore.getUserProfile(uid);
      notifyListeners();
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  void _subscribeToUserPlaces(String uid) {
    print('Subscribing to places for user: $uid');
    _placesSubscription?.cancel();
    _placesSubscription = _firestore.getUserPlaces(uid).listen(
      (places) {
        print('Received ${places.length} places from Firestore');
        _places = places;
        notifyListeners();
      },
      onError: (e) {
        print('Error in places subscription: $e');
      },
    );
  }

  void _unsubscribeFromStreams() {
    _placesSubscription?.cancel();
    _placesSubscription = null;
  }

  @override
  void dispose() {
    _unsubscribeFromStreams();
    super.dispose();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<void> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );
      await _firestore.updateUserProfile(user);
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final userCredential = await _auth.signInWithGoogle();
      final user = userCredential.user!;
      
      final userModel = UserModel(
        uid: user.uid,
        email: user.email!,
        name: user.displayName ?? 'User',
        profilePhotoUrl: user.photoURL,
      );
      await _firestore.updateUserProfile(userModel);
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  Future<void> addPlace(PlaceModel place) async {
    try {
      print('Starting to add place: ${place.title}');
      await _firestore.addPlace(place);
      print('Place added successfully');
    } catch (e) {
      print('Error in addPlace: $e');
      throw Exception('Failed to add place: $e');
    }
  }

  Future<void> updatePlace(PlaceModel place) async {
    try {
      await _firestore.updatePlace(place);
    } catch (e) {
      throw Exception('Failed to update place: $e');
    }
  }

  Future<void> deletePlace(PlaceModel place) async {
    try {
      if (place.imageUrl != null) {
        await _storage.deleteImage(place.imageUrl!);
      }
      await _firestore.deletePlace(place.id);
    } catch (e) {
      throw Exception('Failed to delete place: $e');
    }
  }

  Future<void> updateProfilePhoto(String imageUrl) async {
    try {
      if (_userProfile != null) {
        final updatedProfile = UserModel(
          uid: _userProfile!.uid,
          email: _userProfile!.email,
          name: _userProfile!.name,
          profilePhotoUrl: imageUrl,
        );
        await _firestore.updateUserProfile(updatedProfile);
        _userProfile = updatedProfile;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update profile photo: $e');
    }
  }

  Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end) async {
    try {
      final routeData = await _mapService.getDirections(start, end);
      return routeData['points'];
    } catch (e) {
      throw Exception('Failed to get route: $e');
    }
  }
} 