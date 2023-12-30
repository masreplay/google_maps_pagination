import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTypeController extends StatelessWidget {
  const MapTypeController({
    Key? key,
    required this.currentMapType,
    required this.toggleMapType,
  }) : super(key: key);

  final MapType currentMapType;
  final void Function(MapType) toggleMapType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 2,
        color: Colors.white.withOpacity(0.9),
        child: IconButton(
          icon: const Icon(Icons.map),
          onPressed: () {
            toggleMapType(currentMapType == MapType.normal
                ? MapType.satellite
                : MapType.normal);
          },
        ),
      ),
    );
  }
}
