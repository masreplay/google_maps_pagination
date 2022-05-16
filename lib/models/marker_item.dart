import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MarkerItem {
  // Unique id
  final String id;

  /// Longitude
  final double? lng;

  /// Latitude
  final double? lat;

  /// Map marker label
  final String label;

  const MarkerItem({
    required this.lng,
    required this.id,
    required this.lat,
    required this.label,
  });

  LatLng get location;
}
