import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final LatLng location;
  final String? imageUrl;
  final DateTime createdAt;

  PlaceModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return PlaceModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: LatLng(
        double.parse(map['latitude']?.toString() ?? '0'),
        double.parse(map['longitude']?.toString() ?? '0'),
      ),
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] is String 
          ? DateTime.parse(map['createdAt']) 
          : (map['createdAt']?.toDate() ?? DateTime.now()),
    );
  }
} 