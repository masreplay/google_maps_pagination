import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapZoomController extends StatelessWidget {
  const MapZoomController({
    Key? key,
    this.mapController,
    this.flutterMapController,
    required this.onZoomInPressed,
    required this.onZoomOutPressed,
  }) : super(key: key);

  final GoogleMapController? mapController;
  final MapController? flutterMapController;

  final VoidCallback onZoomInPressed;
  final VoidCallback onZoomOutPressed;

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
        child: Column(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                onZoomInPressed();
                mapController?.animateCamera(CameraUpdate.zoomIn());
                flutterMapController?.move(
                  flutterMapController!.center,
                  flutterMapController!.zoom + 0.1,
                );
              },
            ),
            const SizedBox(height: 2),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                onZoomOutPressed();
                mapController?.animateCamera(CameraUpdate.zoomOut());
                flutterMapController?.move(
                  flutterMapController!.center,
                  flutterMapController!.zoom - 0.1,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
