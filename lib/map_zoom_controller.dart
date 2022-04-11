import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapZoomController extends StatelessWidget {
  const MapZoomController({
    Key? key,
    this.mapController,
    this.onZoomInClick,
    this.onZoomOutClick,
  }) : super(key: key);
  final GoogleMapController? mapController;
  final VoidCallback? onZoomInClick;
  final VoidCallback? onZoomOutClick;

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
                mapController?.animateCamera(CameraUpdate.zoomIn());
                onZoomInClick?.call();
              },
            ),
            const SizedBox(height: 2),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                mapController?.animateCamera(CameraUpdate.zoomOut());
                onZoomOutClick?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
