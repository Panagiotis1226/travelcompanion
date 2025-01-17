import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../widgets/responsive_layout.dart';
import '../providers/app_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final PlaceModel place;

  const PlaceDetailsScreen({required this.place});

  Future<void> _deletePlace(BuildContext context) async {
    try {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text('Delete Place'),
          content: Text('Are you sure you want to delete this place?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        await Provider.of<AppState>(context, listen: false).deletePlace(place);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobilePlaceDetails(place: place, onDelete: () => _deletePlace(context)),
      tablet: _TabletPlaceDetails(place: place, onDelete: () => _deletePlace(context)),
    );
  }
}

class _MobilePlaceDetails extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onDelete;

  const _MobilePlaceDetails({
    required this.place,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (place.imageUrl != null)
              Image.network(
                place.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(place.description),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: place.location,
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId(place.id),
                          position: place.location,
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletPlaceDetails extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onDelete;

  const _TabletPlaceDetails({
    required this.place,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (place.imageUrl != null)
                    Image.network(
                      place.imageUrl!,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(place.description),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: place.location,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(place.id),
                  position: place.location,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
} 