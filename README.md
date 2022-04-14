Pagination markers and cards on map with page view

## Features

Pagination throw google map smoothly

## Getting started

no pre requirements required

## Usage

```dart
final GoogleMapController mapController = GoogleMapController();
final String? selectedItemId = null;

PaginationMap<RealEstate>(
    initialCameraPosition: CameraPosition(target: LatLng(33.4176386794544, 44.34958527530844)),
    currentUserLocation: LatLng(33.4176386794544, 44.34958527530844),
    height: 200,
    pageViewController: PageController(),
    mapController: mapController,
    setMapController: (value) {
        setState(() {
            mapController = value;
        });
    },
    onItemsChanged: (int skip, CameraPosition cameraPosition) async {
        return getItem(skip, cameraPosition)
    },
    pageViewItemBuilder: (BuildContext context, RealEstate item) {
        return RealEstateListTile(item: item);
    },
    selectedItemId: selectedItemId,
    onSelectedItemChanged: (value) {
        setState(() {
            selectedItemId = value;
        });
    },
    labelFormatter: (String label) {
        return "Hello, ${label}";
    },
),

```

## Additional information

Drag map will change camera position and click next or previous will change pagination
