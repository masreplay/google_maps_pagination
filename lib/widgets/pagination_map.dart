import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_pagination/callbacks/callbacks.dart';
import 'package:google_maps_pagination/enums/pagination_state.dart';
import 'package:google_maps_pagination/models/marker_item.dart';
import 'package:google_maps_pagination/models/pagination.dart';
import 'package:google_maps_pagination/widgets/map_zoom_controller.dart';
import 'package:google_maps_pagination/widgets/page_view_over_flow.dart';

import '../makers/marker.dart';
import 'map_pagination_controller.dart';

typedef ItemIdChanged = ValueChanged<String?>;

class PaginationMap<T extends MarkerItem> extends StatefulWidget {
  final CameraPosition initialCameraPosition;

  final GoogleMapController? mapController;

  final ValueChanged<GoogleMapController> setMapController;

  final MapType mapType;

  final String noItemFoundText;

  final int defaultMapTake;

  final ValueReturnChanged<String> markerLabelFormatter;

  final PageController pageViewController;

  final Future<BitmapDescriptor>? markerBitMap;

  final OnItemsChanged<T> onItemsChanged;

  final String? initialSelectedItemId;

  final ItemIdChanged? onSelectedItemIdChanged;

  final ItemsWidgetBuilder<T> itemBuilder;

  final Set<Polyline> polylines;

  final Set<Polygon> polygons;

  final Set<Circle> circles;

  final double? itemScrollZoom;

  final bool zoomGesturesEnabled;

  final bool zoomControlsEnabled;

  final bool rotateGesturesEnabled;

  final bool scrollGesturesEnabled;

  /// Default pageView items height
  /// because horizontal pageView cannot auto measure it's items height
  final double initialHeight;

  final Duration nextRequestDuration;

  final MinMaxZoomPreference minMaxZoomPreference;

  final bool myLocationButtonEnabled;

  final bool indoorViewEnabled;

  final bool trafficEnabled;

  final bool compassEnabled;

  final bool mapToolbarEnabled;

  final bool myLocationEnabled;

  final bool tiltGesturesEnabled;

  final MapPaginationControllerTheme controllerTheme;

  const PaginationMap({
    Key? key,
    required this.initialCameraPosition,
    required this.mapController,
    required this.setMapController,
    required this.pageViewController,
    required this.onItemsChanged,
    required this.markerLabelFormatter,
    required this.itemBuilder,
    required this.controllerTheme,
    this.polygons = const {},
    this.circles = const {},
    this.polylines = const {},
    this.minMaxZoomPreference = const MinMaxZoomPreference(6, null),
    this.initialHeight = 100,
    this.mapType = MapType.normal,
    this.markerBitMap,
    this.nextRequestDuration = const Duration(milliseconds: 500),
    this.defaultMapTake = 25,
    this.noItemFoundText = "no items found...",
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.itemScrollZoom = 16,
    this.myLocationButtonEnabled = false,
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.compassEnabled = false,
    this.mapToolbarEnabled = true,
    this.myLocationEnabled = true,
    this.tiltGesturesEnabled = false,
    this.initialSelectedItemId,
    this.onSelectedItemIdChanged,
  }) : super(key: key);

  @override
  State<PaginationMap<T>> createState() => _PaginationMapState<T>();
}



class _PaginationMapState<T extends MarkerItem> extends State<PaginationMap<T>> {
  List<Marker> _markers = [];

  String? _selectedItemId;

  int _skip = 0;

  Pagination<T> _itemsPagination = Pagination.empty();

  bool _isLoading = false;

  CameraPosition? _cameraPosition;
  Timer? _debounceTimer;
  PaginationState _paginationState = PaginationState.preparing;

  bool _canUpdateMap = true;

  double? _height;

  @override
  void initState() {
    super.initState();
    _height = widget.initialHeight;
    _selectedItemId = widget.initialSelectedItemId;
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
                  onZoomInPressed: _onZoomChanged,
                  onZoomOutPressed: _onZoomChanged,
                ),
              _buildPageView(),
              MapPaginationController(
                skip: _skip,
                limit: widget.defaultMapTake,
                count: _itemsPagination.count,
                isLoading: _isLoading,
                noItemFoundText: widget.noItemFoundText,
                theme: widget.controllerTheme,
                onNextPressed: _onSkipChanged,
                onPreviousPressed: _onSkipChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return GoogleMap(
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      indoorViewEnabled: widget.indoorViewEnabled,
      trafficEnabled: widget.trafficEnabled,
      compassEnabled: widget.compassEnabled,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      myLocationEnabled: widget.myLocationEnabled,
      zoomControlsEnabled: false,
      tiltGesturesEnabled: widget.tiltGesturesEnabled,
      initialCameraPosition: widget.initialCameraPosition,
      minMaxZoomPreference: widget.minMaxZoomPreference,
      markers: Set.from(_markers),
      mapType: widget.mapType,
      zoomGesturesEnabled: widget.zoomGesturesEnabled,
      rotateGesturesEnabled: widget.rotateGesturesEnabled,
      scrollGesturesEnabled: widget.scrollGesturesEnabled,
      gestureRecognizers: const {},
      polygons: widget.polygons,
      circles: widget.circles,
      polylines: widget.polylines,
      onTap: (_) {
        _removeSelection();
      },
      onMapCreated: _onMapCreated,
      onCameraIdle: _onCameraIdle,
      onCameraMove: (position) {
        _cameraPosition = position;
      },
      onCameraMoveStarted: _onCameraMoveStarted,
    );
  }

  Visibility _buildPageView() {
    return Visibility(
      visible: !_canUpdateMap,
      child: SizedBox(
        height: _height,
        child: PageView.builder(
          controller: widget.pageViewController,
          onPageChanged: _onItemChanged,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _itemsPagination.results.length,
          itemBuilder: (BuildContext context, int index) => OverflowBox(
            /// needed, so that parent won't impose its constraints on the children,
            /// thus skewing the measurement results.
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: SizeReportingWidget(
              onSizeChange: (size) {
                setState(() {
                  _height = size?.height;
                });
              },
              child: widget.itemBuilder(
                context,
                _itemsPagination.results[index],
                index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSkipChanged(int skip) async {
    _removeSelection();

    setState(() {
      _skip = skip;
      _isLoading = true;
    });
    await searchByCameraLocation();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onItemChanged(int index) async {
    final item = _itemsPagination.results[index];
    _canUpdateMap = false;
    _onSelectedItemChanged(item.id);

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

  // get new items on location or zoom
  Future<void> searchByCameraLocation() async {
    if (_cameraPosition != null && _canUpdateMap) {
      _itemsPagination = await widget.onItemsChanged(_skip, _cameraPosition!);
      _updateMarkers();
    }
  }

  // generate marker bitmap image to put on map
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

  /// Map's marker pressed
  void _onMarkerPressed(int index) async {
    final item = _itemsPagination.results[index];
    _onSelectedItemChanged(item.id);

    _canUpdateMap = false;

    _updateMarkers();

    // await for [PageView] so we can use the [PageViewController]
    await Future.delayed(const Duration(milliseconds: 100));

    widget.pageViewController.jumpToPage(index);
  }

  Future<void> _updateMarkers() async {
    for (var i = 0; i < _itemsPagination.results.length; i++) {
      final currentElement = _itemsPagination.results[i];
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

    setState(() {
      _markers = _markers;
    });
  }

  // Zoom in-out
  void _onZoomChanged() {
    _skip = 0;

    _removeSelection();
  }

  void _onCameraMoveStarted() {
    _debounceTimer?.cancel();

    _paginationState = PaginationState.dragging;
  }

  void _onCameraIdle() {
    if (_paginationState != PaginationState.dragging) {
      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer!.cancel();
      }
      _debounceTimer = Timer(widget.nextRequestDuration, () {
        _skip = 0;
        searchByCameraLocation();
      });
    }

    _paginationState = PaginationState.idle;
  }

  void _onMapCreated(GoogleMapController controller) {
    widget.setMapController(controller);

    _paginationState = PaginationState.idle;

    _cameraPosition = widget.initialCameraPosition;
    searchByCameraLocation();

    setState(() {});
  }

  void _onSelectedItemChanged(String? id) {
    _selectedItemId = id;
    widget.onSelectedItemIdChanged?.call(id);
    setState(() {});
  }

  // Remove focus from selected marker
  void _removeSelection() {
    _canUpdateMap = true;
    _onSelectedItemChanged(null);
    _updateMarkers();
  }
}
