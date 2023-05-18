// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';

class MapCameraEvent {
  /// Creates a immutable representation of the [GoogleMap] camera.
  ///
  /// [AssertionError] is thrown if [bearing], [target], [tilt], or [zoom] are
  /// null.
  const MapCameraEvent({
    required this.target,
    this.zoom = 0.0,
  });

  /// The geographical location that the camera is pointing at.
  final LatLng target;

  /// The zoom level of the camera.
  ///
  /// A zoom of 0.0, the default, means the screen width of the world is 256.
  /// Adding 1.0 to the zoom level doubles the screen width of the map. So at
  /// zoom level 3.0, the screen width of the world is 2³x256=2048.
  ///
  /// Larger zoom levels thus means the camera is placed closer to the surface
  /// of the Earth, revealing more detail in a narrower geographical region.
  ///
  /// The supported zoom level range depends on the map data and device. Values
  /// beyond the supported range are allowed, but on applying them to a map they
  /// will be silently clamped to the supported range.
  final double zoom;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return other is MapCameraEvent &&
        target == other.target &&
        zoom == other.zoom;
  }

  @override
  int get hashCode => Object.hash(target, zoom);

  @override
  String toString() => 'CameraEvent(target: $target, zoom: $zoom)';

  gmaps.CameraPosition toCameraPosition() {
    return gmaps.CameraPosition(
      target: gmaps.LatLng(target.latitude, target.longitude),
      zoom: zoom,
    );
  }
}
