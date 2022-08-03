import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MarkerItem {
  // Unique id
  final String id;

  /// Map marker label
  final String label;

  const MarkerItem({
    required this.id,
    required this.label,
  });

  LatLng get location;
}
