import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
export 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart' as fmaps;

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
  gmaps.LatLng get gmapsLocation =>
      gmaps.LatLng(location.latitude, location.longitude);

  gmaps.Marker toGmapsMarker({
    required gmaps.BitmapDescriptor markerIcon,
    double zIndex = 0,
    VoidCallback? onTab,
  }) {
    return gmaps.Marker(
      markerId: gmaps.MarkerId(id),
      position: gmapsLocation,
      icon: markerIcon,
      zIndex: zIndex,
      onTap: onTab,
    );
  }

  fmaps.Marker toFmapsMarker({
    required Image markerIcon,
    VoidCallback? onTab,
  }) {
    return fmaps.Marker(
      key: ValueKey(id),
      point: location,
      builder: (_) {
        return GestureDetector(
          onTap: onTab,
          child: markerIcon,
        );
      },
    );
  }
}
