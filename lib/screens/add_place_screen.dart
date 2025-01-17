import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/app_state.dart';
import '../models/place_model.dart';
import '../services/storage_service.dart';

class AddPlaceScreen extends StatefulWidget {
  final LatLng location;

  const AddPlaceScreen({required this.location});

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _storage = StorageService();
  final _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      String? imageUrl;

      if (_imageFile != null) {
        final path = 'places/${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await _storage.uploadImage(_imageFile!, path);
      }

      final place = PlaceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: appState.currentUser!.uid,
        title: _titleController.text,
        description: _descriptionController.text,
        location: widget.location,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await appState.addPlace(place);
      
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Place added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding place: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Place')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a description' : null,
              ),
              SizedBox(height: 16),
              if (_imageFile != null) ...[
                Image.file(
                  _imageFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: Icon(Icons.photo),
                label: Text('Add Photo'),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.location,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('selected'),
                      position: widget.location,
                    ),
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _savePlace,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Save Place'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 