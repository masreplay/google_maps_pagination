import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_pagination/callbacks/callbacks.dart';
import 'package:google_maps_pagination/enums/pagination_state.dart';
import 'package:google_maps_pagination/models/marker_item.dart';
import 'package:google_maps_pagination/models/pagination.dart';
import 'package:google_maps_pagination/widgets/map_type_controller.dart';
import 'package:google_maps_pagination/widgets/map_zoom_controller.dart';
import 'package:google_maps_pagination/widgets/page_view_over_flow.dart';

import '../makers/marker.dart';
import 'map_pagination_controller.dart';

extension CameraPositionExtensions on CameraPosition {
  bool isSame(CameraPosition? other) {
    return target.latitude.toStringAsFixed(2) ==
            other?.target.latitude.toStringAsFixed(2) &&
        target.longitude.toStringAsFixed(2) ==
            other?.target.longitude.toStringAsFixed(2);
  }
}

class PaginationMap<T extends MarkerItem> extends StatefulWidget {
  final CameraPosition initialCameraPosition;

  final GoogleMapController? mapController;

  final ValueChanged<GoogleMapController> setMapController;
  final ValueChanged<VoidCallback>? setRestCallback;

  final MapType mapType;

  final String noItemFoundText;

  final MapPaginationControllerTheme controllerTheme;

  final int defaultMapTake;

  final ValueReturnChanged<String> markerLabelFormatter;

  final PageController pageViewController;

  final Future<BitmapDescriptor>? markerBitMap;

  final OnItemsChanged<T> onItemsChanged;

  final String? selectedItemId;

  final ValueChanged<String?> onSelectedItemChanged;

  final ItemsWidgetBuilder<T> itemBuilder;

  final Set<Polyline> polylines;

  final Set<Polygon> polygons;

  final Set<Circle> circles;

  final double? itemScrollZoom;

  final bool zoomGesturesEnabled;

  final bool zoomControlsEnabled;

  final bool mapTypeControlsEnabled;

  final bool rotateGesturesEnabled;

  final bool scrollGesturesEnabled;

  /// Default pageView items height
  /// because horizontal pageView cannot auto measure it's items height
  final double initialHeight;

  final Duration nextRequestDuration;

  final MinMaxZoomPreference minMaxZoomPreference;

  /// This default behavior of resending the request on camera move will be
  /// disabled if this flag is set to true, otherwise it will call onItemsChanged
  /// on every camera move
  final bool disableCameraUpdateRequest;

  /// This default behavior of resending the request on Zoom change will be
  /// disabled if this flag is set to true, otherwise it will call
  /// onSelectedItemChanged(null) and reset the pagination
  /// on every Zoom change
  final bool disableZoomChangeRequest;

  final VoidCallback? onMiddleTextPressed;

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
    required this.itemBuilder,
    required this.controllerTheme,
    this.setRestCallback,
    this.minMaxZoomPreference = const MinMaxZoomPreference(6, null),
    this.initialHeight = 100,
    this.mapType = MapType.normal,
    this.markerBitMap,
    this.nextRequestDuration = const Duration(milliseconds: 500),
    this.defaultMapTake = 25,
    this.noItemFoundText = "no items found...",
    this.polygons = const {},
    this.circles = const {},
    this.polylines = const {},
    this.zoomControlsEnabled = true,
    this.mapTypeControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.itemScrollZoom = 16,
    this.disableCameraUpdateRequest = false,
    this.disableZoomChangeRequest = false,
    this.onMiddleTextPressed,
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

  bool _isLoading = false;

  CameraPosition? _cameraPosition;
  CameraPosition? _oldPosition;

  Timer? _debounceTimer;
  PaginationState _paginationState = PaginationState.preparing;

  bool _canSendRequest = true;

  double? _height;

  bool get isItemSelected => widget.selectedItemId != null;

  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _height = widget.initialHeight;
    _currentMapType = widget.mapType;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          _buildGoogleMap(context),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.zoomControlsEnabled)
                MapZoomController(
                  mapController: widget.mapController,
                  onZoomInPressed: _onZoomClick,
                  onZoomOutPressed: _onZoomClick,
                ),
              if (widget.mapTypeControlsEnabled)
                MapTypeController(
                  currentMapType: _currentMapType,
                  toggleMapType: _onMapTypeChanged,
                ),
              Visibility(
                visible: !_canSendRequest,
                child: SizedBox(
                  height: _height,
                  child: PageView.builder(
                    controller: widget.pageViewController,
                    onPageChanged: _onItemChanged,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _items.results.length,
                    itemBuilder: (BuildContext context, int index) {
                      return OverflowBox(
                        /// needed, so that parent won't impose its constraints on the children,
                        /// thus skewing the measurement results.
                        minHeight: 0,
                        maxHeight: double.infinity,
                        alignment: Alignment.topCenter,
                        child: SizeReportingWidget(
                          onSizeChange: (size) {
                            setState(() => _height = size?.height);
                            if (kDebugMode) {
                              log("Pagination map ${widget.initialHeight} - $size");
                            }
                          },
                          child: widget.itemBuilder(
                              context, _items.results[index], index),
                        ),
                      );
                    },
                  ),
                ),
              ),
              MapPaginationController(
                skip: skip,
                limit: widget.defaultMapTake,
                count: _items.count,
                isLoading: _isLoading,
                noItemFoundText: widget.noItemFoundText,
                theme: widget.controllerTheme,
                onNextPressed: _onSkipChange,
                onPreviousPressed: _onSkipChange,
                onMiddleTextPressed: widget.onMiddleTextPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void reset() async {
    skip = 0;
    _selectedItemId = null;
    _canSendRequest = true;
    widget.onSelectedItemChanged(_selectedItemId);
    await _sendRequest();
  }

  void onSelectedItemChanged(String? id) {
    _selectedItemId = id;
    setState(() {});
    widget.onSelectedItemChanged(id);
  }

  Future<void> _onSkipChange(int skip) async {
    _canSendRequest = true;
    onSelectedItemChanged(null);
    this.skip = skip;
    await _sendRequest();
  }

  Future<void> _onItemChanged(int index) async {
    final item = _items.results[index];
    _canSendRequest = false;
    _selectedItemId = item.id;
    onSelectedItemChanged(item.id);

    widget.mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        widget.itemScrollZoom == null
            ? CameraPosition(target: item.location)
            : CameraPosition(
                target: item.location,
                zoom: widget.itemScrollZoom!,
              ),
      ),
    );
    _updateMarkers();
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
      initialCameraPosition: widget.initialCameraPosition,
      minMaxZoomPreference: widget.minMaxZoomPreference,
      markers: Set.from(markers),
      mapType: _currentMapType,
      zoomGesturesEnabled: widget.zoomGesturesEnabled,
      rotateGesturesEnabled: widget.rotateGesturesEnabled,
      scrollGesturesEnabled: widget.scrollGesturesEnabled,
      gestureRecognizers: const {},
      polygons: widget.polygons,
      circles: widget.circles,
      polylines: widget.polylines,
      onTap: _onMapTap,
      onMapCreated: _onMapCreated,
      onCameraIdle: _onCameraIdle,
      onCameraMove: _onCameraMove,
      onCameraMoveStarted: _onCameraMoveStarted,
    );
  }

  Future searchByCameraLocation() async {
    if (widget.disableCameraUpdateRequest &&
        (_cameraPosition!.isSame(_oldPosition))) return;
    _sendRequest();
  }

  Future<void> _sendRequest() async {
    setState(() => _isLoading = true);
    _oldPosition = _cameraPosition;
    if (_cameraPosition != null && _canSendRequest) {
      _items = await widget.onItemsChanged(skip, _cameraPosition!);
      _updateMarkers();
    }
    setState(() => _isLoading = false);
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

  void _onMarkerPressed(int index) async {
    final item = _items.results[index];
    _canSendRequest = false;

    setState(() => _selectedItemId = item.id);

    _selectedItemId = item.id;
    await Future.delayed(const Duration(milliseconds: 100));
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
        onTap: () => _onMarkerPressed(i),
      );

      _markers.add(marker);
    }

    setState(() => markers = _markers);
  }

  void _onZoomClick() {
    if (widget.disableZoomChangeRequest) return;
    skip = 0;
    onSelectedItemChanged(null);
    setState(() {
      _canSendRequest = true;
    });
  }

  void _onMapTypeChanged(MapType mapType) {
    setState(() => _currentMapType = mapType);
  }

  void _onCameraMove(CameraPosition position) {
    _oldPosition = _cameraPosition;

    if (!widget.disableCameraUpdateRequest) _cameraPosition = position;
    if (!_cameraPosition!.isSame(widget.initialCameraPosition)) {
      _cameraPosition = widget.initialCameraPosition;
      skip = 0;
    }
  }

  void _onCameraMoveStarted() {
    _debounceTimer?.cancel();

    _paginationState = PaginationState.dragging;
  }

  void _onCameraIdle() {
    if (_paginationState == PaginationState.dragging) {
      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer!.cancel();
      }
      _debounceTimer = Timer(widget.nextRequestDuration, () {
        if (!widget.disableCameraUpdateRequest) skip = 0;
        searchByCameraLocation();
      });
    }

    _paginationState = PaginationState.idle;
  }

  void _onMapCreated(GoogleMapController controller) {
    widget.setMapController(controller);
    widget.setRestCallback?.call(reset);

    _paginationState = PaginationState.idle;

    _cameraPosition = widget.initialCameraPosition;

    searchByCameraLocation();

    setState(() {});
  }

  void _onMapTap(LatLng argument) {
    _canSendRequest = true;
    _selectedItemId = null;
    _updateMarkers();
  }
}
