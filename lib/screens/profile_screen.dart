import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/app_state.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  final StorageService _storage = StorageService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _updateProfilePhoto(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final appState = Provider.of<AppState>(context, listen: false);
      final String userId = appState.currentUser!.uid;
      final String? oldPhotoUrl = appState.userProfile?.profilePhotoUrl;
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading photo...')),
      );
      
      // Delete old photo if it exists
      if (oldPhotoUrl != null) {
        print('Deleting old profile photo: $oldPhotoUrl');
        await _storage.deleteImage(oldPhotoUrl);
      }
      
      final String path = 'profile_photos/$userId.jpg';
      print('Uploading new image to path: $path');
      
      final String imageUrl = await _storage.uploadImage(File(image.path), path);
      print('New image uploaded, URL: $imageUrl');
      
      await appState.updateProfilePhoto(imageUrl);
      print('Profile photo updated in Firestore');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating profile photo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile photo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await Provider.of<AppState>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final user = appState.userProfile;
          print('Building profile with photo URL: ${user?.profilePhotoUrl}'); // Debug print
          
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _updateProfilePhoto(context),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profilePhotoUrl != null
                            ? NetworkImage(user.profilePhotoUrl!) as ImageProvider
                            : const AssetImage('assets/default_profile.png'),
                        child: user.profilePhotoUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.place),
                  title: const Text('My Places'),
                  trailing: Text(
                    appState.places.length.toString(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 