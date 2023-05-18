import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_pagination/callbacks/callbacks.dart';
import 'package:google_maps_pagination/enums/pagination_state.dart';
import 'package:google_maps_pagination/makers/marker.dart';
import 'package:google_maps_pagination/models/camera_event.dart';
import 'package:google_maps_pagination/models/marker_item.dart';
import 'package:google_maps_pagination/models/pagination.dart';
import 'package:google_maps_pagination/widgets/map_zoom_controller.dart';
import 'package:google_maps_pagination/widgets/page_view_over_flow.dart';

import 'map_pagination_controller.dart';

class MapConstants {
  static const String mapBoxAccessToken =
      'pk.eyJ1IjoiYmlsYWxyYWQiLCJhIjoiY2xocGQ2MHNkMjUzNjNsbnhqN3ExcG5iYiJ9.4CE7XTlx_WnS3zJSYgHDpw';

  static const String mapBoxStyleLink =
      'https://api.mapbox.com/styles/v1/bilalrad/ckmb04pqdhzg917o4x2i8q46h/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYmlsYWxyYWQiLCJhIjoiY2xocGQ2MHNkMjUzNjNsbnhqN3ExcG5iYiJ9.4CE7XTlx_WnS3zJSYgHDpw';

  static const String mapBoxStyleId = 'ckmb04pqdhzg917o4x2i8q46h';
}

extension CameraPositionExtensions on MapCameraEvent {
  bool isSame(MapCameraEvent? other) {
    return target.latitude.toStringAsFixed(2) ==
            other?.target.latitude.toStringAsFixed(2) &&
        target.longitude.toStringAsFixed(2) ==
            other?.target.longitude.toStringAsFixed(2);
  }
}

class PaginationMapBox<T extends MarkerItem> extends StatefulWidget {
  final MapCameraEvent initialCameraPosition;

  final MapController? mapController;

  final ValueChanged<MapController> setMapController;
  final ValueChanged<VoidCallback>? setRestCallback;

  final String noItemFoundText;

  final MapPaginationControllerTheme controllerTheme;

  final int defaultMapTake;

  final ValueReturnChanged<String> markerLabelFormatter;

  final PageController pageViewController;

  final String? markerImage;

  final OnItemsChanged<T> onItemsChanged;

  final String? selectedItemId;

  final ValueChanged<String?> onSelectedItemChanged;

  final ItemsWidgetBuilder<T> itemBuilder;

  final List<Polyline> polylines;

  final List<Polygon> polygons;

  final List<CircleMarker> circles;

  final double? itemScrollZoom;

  final bool zoomGesturesEnabled;

  final bool zoomControlsEnabled;

  final bool rotateGesturesEnabled;

  final bool scrollGesturesEnabled;

  /// Default pageView items height
  /// because horizontal pageView cannot auto measure it's items height
  final double initialHeight;

  final Duration nextRequestDuration;

  /// The preferred minimum zoom level or null, if unbounded from below.
  final double? minZoom;

  /// The preferred maximum zoom level or null, if unbounded from above.
  final double? maxZoom;

  /// This default behavior of resending the request on camera move will be
  /// disabled if this flag is set to true, otherwise it will call onItemsChanged
  /// on every camera move
  final bool disableCameraUpdateRequest;

  final VoidCallback? onMiddleTextPressed;

  const PaginationMapBox({
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
    this.minZoom = 6,
    this.maxZoom,
    this.initialHeight = 100,
    this.markerImage,
    this.nextRequestDuration = const Duration(milliseconds: 500),
    this.defaultMapTake = 25,
    this.noItemFoundText = "no items found...",
    this.polygons = const [],
    this.circles = const [],
    this.polylines = const [],
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.itemScrollZoom = 16,
    this.disableCameraUpdateRequest = false,
    this.onMiddleTextPressed,
  }) : super(key: key);

  @override
  State<PaginationMapBox<T>> createState() => _PaginationMapBoxState<T>();
}

class _PaginationMapBoxState<T extends MarkerItem>
    extends State<PaginationMapBox<T>> {
  String? _selectedItemId;

  List<Marker> markers = [];
  int skip = 0;
  Pagination<T> _items = Pagination.empty();

  bool _isLoading = false;

  MapCameraEvent? _cameraPosition;
  MapCameraEvent? _oldPosition;

  Timer? _debounceTimer;
  PaginationState _paginationState = PaginationState.preparing;

  bool _canSendRequest = true;

  double? _height;

  bool get isItemSelected => widget.selectedItemId != null;

  @override
  void initState() {
    super.initState();
    _height = widget.initialHeight;
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
                  flutterMapController: widget.mapController,
                  onZoomInPressed: _onZoomClick,
                  onZoomOutPressed: _onZoomClick,
                ),
              // visible: _items.isNotEmpty && _selectedItemId != null,
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

    widget.mapController?.move(
      item.location,
      widget.itemScrollZoom == null
          ? widget.initialCameraPosition.zoom
          : widget.itemScrollZoom!,
    );
    _updateMarkers();
  }

  Widget _buildGoogleMap(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        minZoom: widget.minZoom,
        maxZoom: widget.maxZoom,
        center: widget.initialCameraPosition.target,
        onMapReady: _onMapCreated,
        onMapEvent: (p0) {
          print(p0.zoom);
          print(p0.source);
        },
        onLongPress: (tapPosition, point) {
          print(point);
        },
        onPositionChanged: _onCameraMove,
        onTap: _onMapTap,
      ),
      children: [
        TileLayer(
          urlTemplate: MapConstants.mapBoxStyleLink,
          additionalOptions: const {
            'mapStyleId': MapConstants.mapBoxStyleId,
            'accessToken': MapConstants.mapBoxAccessToken,
          },
        ),
        PolygonLayer(
          polygons: widget.polygons,
        ),
        PolylineLayer(
          polylines: widget.polylines,
        ),
        CircleLayer(
          circles: widget.circles,
        ),
      ],
      // myLocationButtonEnabled: false,
      // indoorViewEnabled: false,
      // trafficEnabled: false,
      // compassEnabled: false,
      // mapToolbarEnabled: false,
      // myLocationEnabled: true,
      // zoomControlsEnabled: false,
      // tiltGesturesEnabled: false,
      // initialCameraPosition: widget.initialCameraPosition,
      // minMaxZoomPreference: widget.minMaxZoomPreference,
      // markers: Set.from(markers),
      // mapType: widget.mapType,
      // zoomGesturesEnabled: widget.zoomGesturesEnabled,
      // rotateGesturesEnabled: widget.rotateGesturesEnabled,
      // scrollGesturesEnabled: widget.scrollGesturesEnabled,
      // gestureRecognizers: const {},
      // polygons: widget.polygons,
      // circles: widget.circles,
      // polylines: widget.polylines,
      // onCameraIdle: _onCameraIdle,
      // onCameraMoveStarted: _onCameraMoveStarted,
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

      final markerIcon = await _getMarkerBitMap(
        isSelected,
        widget.markerLabelFormatter(currentElement.label),
      );

      final marker = currentElement.toFmapsMarker(
        markerIcon: markerIcon,
        onTab: () => _onMarkerPressed(i),
      );

      _markers.add(marker);
    }

    setState(() => markers = _markers);
  }

  Future<Image> _getMarkerBitMap(
    bool isSelected,
    String label,
  ) async {
    return Image.memory((await getMarkerUnit8List(
      text: widget.markerLabelFormatter(label),
      textColor: isSelected ? Colors.black : Colors.white,
      color:
          isSelected ? const Color(0xffeaa329) : Theme.of(context).primaryColor,
    )));
  }

  void _onZoomClick() {
    skip = 0;
    onSelectedItemChanged(null);
    setState(() {
      _canSendRequest = true;
    });
  }

  void _onCameraMove(MapPosition position, bool hasGesture) {
    _oldPosition = _cameraPosition;

    if (!widget.disableCameraUpdateRequest) {
      _cameraPosition = MapCameraEvent(
        target: position.center!,
        zoom: position.zoom ?? widget.initialCameraPosition.zoom,
      );
    }
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

  void _onMapCreated() {
    widget.setMapController(MapController());
    widget.setRestCallback?.call(reset);

    _paginationState = PaginationState.idle;

    _cameraPosition = widget.initialCameraPosition;

    searchByCameraLocation();

    setState(() {});
  }

  void _onMapTap(TapPosition position, LatLng latLng) {
    _canSendRequest = true;
    _selectedItemId = null;
    _updateMarkers();
  }
}
