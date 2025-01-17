import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/location_service.dart';
import '../models/place_model.dart';
import './add_place_screen.dart';
import './place_details_screen.dart';
import '../services/map_service.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final MapService _mapService = MapService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  LatLng? _startPoint;
  LatLng? _endPoint;
  bool _isRoutingMode = false;
  String? _distance;
  String? _duration;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedPlaces();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await _locationService.getLatLng();
      setState(() {
        _currentLocation = location;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _loadSavedPlaces() {
    if (!mounted) return;
    
    final places = Provider.of<AppState>(context, listen: false).places;
    print('Loading places: ${places.length}');
    
    try {
      setState(() {
        // Clear existing place markers (keep routing markers if they exist)
        _markers.removeWhere((marker) => 
          marker.markerId.value != 'start' && 
          marker.markerId.value != 'end'
        );
        
        // Add new markers from places
        _markers.addAll(places.map((place) {
          print('Creating marker for place: ${place.id}');
          return Marker(
            markerId: MarkerId(place.id),
            position: place.location,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceDetailsScreen(place: place),
                ),
              );
            },
            infoWindow: InfoWindow(
              title: place.title,
              snippet: place.description,
            ),
          );
        }));
      });
    } catch (e) {
      print('Error creating markers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading places: $e')),
      );
    }
  }

  Future<void> _onMapTap(LatLng position) async {
    if (_isRoutingMode) {
      _handleRoutingTap(position);
    } else {
      _showAddPlaceScreen(position);
    }
  }

  void _handleRoutingTap(LatLng position) {
    setState(() {
      if (_startPoint == null) {
        _startPoint = position;
        _markers.add(Marker(
          markerId: MarkerId('start'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
      } else if (_endPoint == null) {
        _endPoint = position;
        _markers.add(Marker(
          markerId: MarkerId('end'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
        _getRoute();
      }
    });
  }

  Future<void> _showAddPlaceScreen(LatLng location) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPlaceScreen(location: location),
      ),
    );

    if (result == true && mounted) {
      _loadSavedPlaces();
    }
  }

  Future<void> _getRoute() async {
    if (_startPoint == null || _endPoint == null) return;

    try {
      final routeData = await _mapService.getDirections(_startPoint!, _endPoint!);
      
      setState(() {
        _polylines.clear(); // Clear existing routes
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: routeData['points'],
            color: Colors.blue,
            width: 5,
          ),
        );
        _distance = routeData['distance'];
        _duration = routeData['duration'];
      });

      // Fit the map to show the entire route
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(routeData['bounds'], 50),
      );

      // Show route info in a persistent bottom sheet
      if (mounted) {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Route Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.directions_car),
                        Text(_distance ?? ''),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.access_time),
                        Text(_duration ?? ''),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _clearRoute,
                  child: Text('Clear Route'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting route: $e')),
      );
    }
  }

  void _clearRoute() {
    setState(() {
      _startPoint = null;
      _endPoint = null;
      _polylines.clear();
      _markers.removeWhere(
        (m) => m.markerId.value == 'start' || m.markerId.value == 'end',
      );
      _isRoutingMode = false;
    });
    _loadSavedPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (_currentLocation == null) {
            return Center(child: CircularProgressIndicator());
          }
          
          print('Building map with ${appState.places.length} places'); // Debug print
          
          return GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _loadSavedPlaces(); // Reload places when map is created
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation!,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            polylines: _polylines,
            onTap: _onMapTap,
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'location',
            onPressed: _getCurrentLocation,
            child: Icon(Icons.my_location),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'route',
            onPressed: () {
              setState(() {
                _isRoutingMode = !_isRoutingMode;
                if (!_isRoutingMode) _clearRoute();
              });
            },
            child: Icon(_isRoutingMode ? Icons.close : Icons.directions),
          ),
        ],
      ),
    );
  }
} 