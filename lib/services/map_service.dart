import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/maps_config.dart';

class MapService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  Future<Map<String, dynamic>> getDirections(LatLng origin, LatLng destination) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=${MapsConfig.apiKey}'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        // Get the first route
        final route = data['routes'][0];
        final leg = route['legs'][0];
        
        return {
          'points': _decodePolyline(route['overview_polyline']['points']),
          'bounds': LatLngBounds(
            southwest: LatLng(
              route['bounds']['southwest']['lat'],
              route['bounds']['southwest']['lng'],
            ),
            northeast: LatLng(
              route['bounds']['northeast']['lat'],
              route['bounds']['northeast']['lng'],
            ),
          ),
          'distance': leg['distance']['text'],
          'duration': leg['duration']['text'],
          'startAddress': leg['start_address'],
          'endAddress': leg['end_address'],
        };
      }
    }
    throw Exception('Failed to fetch directions');
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
} 