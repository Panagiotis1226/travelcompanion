import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file, String folderPath) async {
    try {
      // Get MIME type
      final mimeType = lookupMimeType(file.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw Exception('Invalid image file');
      }

      // Create a unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final ref = _storage.ref().child('$folderPath/$fileName');

      // Upload with proper metadata
      final metadata = SettableMetadata(
        contentType: mimeType,
        cacheControl: 'public, max-age=31536000',
      );

      // Perform upload
      final uploadTask = await ref.putFile(file, metadata);
      
      // Return download URL
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Storage error details: $e'); // Detailed error logging
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
      print('Successfully deleted image: $imageUrl');
    } catch (e) {
      print('Error deleting image: $e');
      throw Exception('Failed to delete image: $e');
    }
  }
} 