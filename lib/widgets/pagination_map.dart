import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_pagination/callbacks/callbacks.dart';
import 'package:google_maps_pagination/enums/pagination_state.dart';
import 'package:google_maps_pagination/models/marker_item.dart';
import 'package:google_maps_pagination/models/pagination.dart';

import '../makers/marker.dart';

class PaginationMap<T extends MarkerItem> extends StatefulWidget {
  final CameraPosition initialCameraPosition;

  final GoogleMapController? mapController;

  final ValueChanged<GoogleMapController> setMapController;

  final MapType mapType;

  final String noItemFoundText;

  final TextStyle? controllerTextStyle;

  final Color controllerColor;

  final Color backgroundColor;

  final Color textColor;

  final int defaultMapTake;

  final ValueReturnChanged<String> markerLabelFormatter;

  final PageController pageViewController;

  final Future<BitmapDescriptor>? markerBitMap;

  final OnItemsChanged<T> onItemsChanged;

  final String? selectedItemId;

  final ValueChanged<String?> onSelectedItemChanged;

  final ItemsWidgetBuilder<T> pageViewItemBuilder;

  final Set<Polygon> polygons;

  /// Default pageView items height
  /// because horizontal pageView cannot auto measure it's items height
  final double initialHeight;

  final Duration nextRequestDuration;

  const PaginationMap({
    Key? key,
    required this.initialCameraPosition,
    required this.mapController,
    required this.setMapController,
    required this.pageViewController,
    required this.onItemsChanged,
    required this.markerLabelFormatter,
    required this.selectedItemId,
    required this.onSelectedItemChanged,
    required this.pageViewItemBuilder,
    this.initialHeight = 100,
    this.mapType = MapType.normal,
    this.markerBitMap,
    this.nextRequestDuration = const Duration(milliseconds: 500),
    this.defaultMapTake = 25,
    this.noItemFoundText = "no items found...",
    this.controllerColor = const Color(0xFF007bff),
    this.backgroundColor = const Color(0xFFFFDA85),
    this.textColor = Colors.black,
    this.controllerTextStyle,
    this.polygons = const {},
  }) : super(key: key);

  @override
  State<PaginationMap<T>> createState() => _PaginationMapState<T>();
}

class _PaginationMapState<T extends MarkerItem>
    extends State<PaginationMap<T>> {
  String? _selectedItemId;

  List<Marker> markers = [];
  int skip = 0;
  Pagination<T> _items = Pagination.empty();

  CameraPosition? _cameraPosition;
  Timer? _debounceTimer;
  PaginationState _paginationState = PaginationState.preparing;

  bool _canUpdateMap = true;

  bool get isItemSelected => widget.selectedItemId != null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildGoogleMap(context),
      ],
    );
  }



  Widget _buildGoogleMap(BuildContext context) {
    return GoogleMap(
      myLocationButtonEnabled: false,
      indoorViewEnabled: false,
      trafficEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      tiltGesturesEnabled: false,
      onTap: (_) {
        _canUpdateMap = true;
        _selectedItemId = null;
        _updateMarkers();
      },
      initialCameraPosition: widget.initialCameraPosition,
      minMaxZoomPreference: const MinMaxZoomPreference(6, null),
      markers: Set.from(markers),
      mapType: widget.mapType,
      onMapCreated: (GoogleMapController controller) async {
        widget.setMapController(controller);

        _paginationState = PaginationState.idle;

        _cameraPosition = widget.initialCameraPosition;
        searchByCameraLocation();

        setState(() {});
      },
      onCameraIdle: () {
        if (_paginationState == PaginationState.dragging) {
          if (_debounceTimer?.isActive ?? false) {
            _debounceTimer!.cancel();
          }
          _debounceTimer = Timer(widget.nextRequestDuration, () {
            skip = 0;
            searchByCameraLocation();
          });
        }

        _paginationState = PaginationState.idle;
      },
      onCameraMoveStarted: () {
        _debounceTimer?.cancel();

        _paginationState = PaginationState.dragging;
      },
      onCameraMove: (CameraPosition position) {
        _cameraPosition = position;
      },
      gestureRecognizers: const {},
      polygons: widget.polygons,
    );
  }

  Future searchByCameraLocation() async {
    if (_cameraPosition != null && _canUpdateMap) {
      _items = await widget.onItemsChanged(skip, _cameraPosition!);
      _updateMarkers();
    }
  }

  Future<BitmapDescriptor> _getMarkerBitMap(
    bool isSelected,
    String label,
  ) async {
    return await getMarkerBitmap(
      text: widget.markerLabelFormatter(label),
      textColor: isSelected ? Colors.black : Colors.white,
      color:
          isSelected ? const Color(0xffeaa329) : Theme.of(context).primaryColor,
    );
  }

  void _onMarkerTapped(int index) async {
    final item = _items.results[index];
    _canUpdateMap = false;
    if (_selectedItemId == null) {
      // the pageView is currently invisible
      setState(() {
        _selectedItemId = item.id;
      });
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _selectedItemId = item.id;

    widget.pageViewController.jumpToPage(index);
    _updateMarkers();
  }

  Future<void> _updateMarkers() async {
    final _markers = <Marker>[];

    for (var i = 0; i < _items.results.length; i++) {
      final currentElement = _items.results[i];
      final isSelected = _selectedItemId == currentElement.id;

      final markerIcon = await widget.markerBitMap ??
          await _getMarkerBitMap(isSelected, currentElement.label);

      final marker = Marker(
        markerId: MarkerId(currentElement.id),
        position: currentElement.location,
        icon: markerIcon,
        zIndex: isSelected ? 1 : 0,
        onTap: () => _onMarkerTapped(i),
      );

      _markers.add(marker);
    }

    setState(() {
      markers = _markers;
    });
  }

}
