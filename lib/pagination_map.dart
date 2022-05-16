import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_pagination/map_zoom_controller.dart';
import 'package:google_maps_pagination/marker_item.dart';
import 'package:google_maps_pagination/page_view_over_flow.dart';
import 'package:google_maps_pagination/pagination.dart';
import 'package:google_maps_pagination/pagination_state.dart';

import '../callbacks.dart';
import 'map_pagination_controller.dart';
import 'marker.dart';

const int defaultMapTake = 25;

class PaginationMap<T extends MarkerItem> extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final LatLng? currentUserLocation;

  final GoogleMapController? mapController;
  final ValueChanged<GoogleMapController> setMapController;

  final MapType mapType;

  final ValueReturnChanged<String> labelFormatter;
  final PageController pageViewController;

  final OnItemsChanged<T> onItemsChanged;

  final String? selectedItemId;
  final ValueChanged<String?> onSelectedItemChanged;

  final ItemsWidgetBuilder<T> pageViewItemBuilder;

  /// Default pageView items height
  /// because horizontal pageView cannot auto measure it's items height
  final double height;

  const PaginationMap({
    Key? key,
    required this.initialCameraPosition,
    required this.setMapController,
    required this.currentUserLocation,
    required this.mapController,
    required this.pageViewController,
    required this.onItemsChanged,
    required this.labelFormatter,
    required this.selectedItemId,
    required this.onSelectedItemChanged,
    required this.pageViewItemBuilder,
    required this.height,
    this.mapType = MapType.normal,
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
  Timer? _debounceTimer;
  PaginationState _paginationState = PaginationState.preparing;

  bool _canUpdateMap = true;

  double? _height;

  bool get isItemSelected => widget.selectedItemId != null;

  @override
  void initState() {
    _height = widget.height;
    super.initState();
  }

  onItemChanged(int index) async {
    debugPrint('on item changed has been called');
    var item = _items.results[index];
    _canUpdateMap = false;
    _selectedItemId = item.id;
    widget.onSelectedItemChanged(item.id);
    widget.mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
          target: item.location,
          zoom: await widget.mapController!.getZoomLevel())),
    );
    _updateMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          buildGoogleMap(context),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // log
              if (kDebugMode)
                _canUpdateMap
                    ? const Text(
                        "CAN",
                        style: TextStyle(
                          color: Colors.green,
                          backgroundColor: Colors.white,
                        ),
                      )
                    : const Text(
                        "CANNOT",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
              MapZoomController(
                mapController: widget.mapController,
                onZoomInClick: _onZoomClick,
                onZoomOutClick: _onZoomClick,
              ),
              Visibility(
                // visible: _items.isNotEmpty && _selectedItemId != null,
                visible: !_canUpdateMap,
                child: SizedBox(
                  height: _height,
                  child: PageView.builder(
                    controller: widget.pageViewController,
                    onPageChanged: onItemChanged,
                    scrollDirection: Axis.horizontal,
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
                            setState(() {
                              _height = size?.height;
                            });
                            if (kDebugMode) {
                              print("LOG: baity map ${widget.height} - $size");
                            }
                          },
                          child: widget.pageViewItemBuilder(
                              context, _items.results[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),
              MapPaginationController(
                skip: skip,
                take: defaultMapTake,
                count: _items.count,
                isLoading: _isLoading,
                onNextPressed: onSkipChange,
                onPreviousPressed: onSkipChange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> onSkipChange(int skip) async {
    _canUpdateMap = true;
    widget.onSelectedItemChanged(null);
    setState(() {
      this.skip = skip;
      _isLoading = true;
    });
    await searchByCameraLocation();
    setState(() {
      _isLoading = false;
    });
  }

  Widget buildGoogleMap(BuildContext context) {
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
        debugPrint('on Camera Idle');
        if (_paginationState == PaginationState.dragging) {
          if (_debounceTimer?.isActive ?? false) {
            _debounceTimer!.cancel();
          }
          _debounceTimer = Timer(const Duration(milliseconds: 500), () {
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
    );
  }

  Future searchByCameraLocation() async {
    if (_cameraPosition != null && _canUpdateMap) {
      _items = await widget.onItemsChanged(skip, _cameraPosition!);
      _updateMarkers();
    }
  }

  Future<BitmapDescriptor> _getMarkerBitMap(
      bool isSelected, String label) async {
    return await getMarkerBitmap(
      text: widget.labelFormatter(label),
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

  Future<void> _updateMarkers([bool dis = true]) async {
    final _markers = <Marker>[];

    for (var i = 0; i < _items.results.length; i++) {
      final currentElement = _items.results[i];
      var _isSelected = dis && _selectedItemId == currentElement.id;

      final markerIcon =
          await _getMarkerBitMap(_isSelected, currentElement.label);

      final marker = Marker(
        markerId: MarkerId(currentElement.id),
        position: currentElement.location,
        icon: markerIcon,
        onTap: () => _onMarkerTapped(i),
      );

      _markers.add(marker);
    }

    setState(() {
      markers = _markers;
    });
  }

  void _onZoomClick() {
    skip = 0;
    widget.onSelectedItemChanged(null);
    setState(() {
      _canUpdateMap = true;
    });
  }
}
