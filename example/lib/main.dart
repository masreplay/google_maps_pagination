import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_pagination/google_maps_pagination.dart';
import 'package:google_maps_pagination/models/models.dart';

void main() {
  runApp(const MyApp());
}

class RealEstate extends MarkerItem {
  final int age;
  final String imageUrl;

  @override
  final LatLng location;

  const RealEstate({
    required super.id,
    required super.label,
    required this.age,
    required this.imageUrl,
    required this.location,
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static const initialCameraPosition = CameraPosition(
    target: LatLng(33.43732827389199, 44.3542279671069),
    zoom: 10,
  );

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  GoogleMapController? _mapController;
  String? _selectedItemId;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PaginationMap<RealEstate>(
          initialCameraPosition: MyApp.initialCameraPosition,
          mapController: _mapController,
          initialHeight: 100,
          pageViewController: _pageController,
          setMapController: (value) {
            setState(() {
              _mapController = value;
            });
          },
          onItemsChanged: getFakeItems,
          markerLabelFormatter: (value) {
            return "$value USD";
          },
          selectedItemId: _selectedItemId,
          onSelectedItemChanged: (value) {
            setState(() {
              _selectedItemId = value;
            });
          },
          itemBuilder: (BuildContext context, RealEstate item, int index) {
            return ItemListTile(item: item, index: index);
          },
        ),
      ),
    );
  }
}

class ItemListTile extends StatelessWidget {
  final RealEstate item;
  final int index;
  const ItemListTile({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Row(
        children: [
          Image.network(
            item.imageUrl,
            width: 100,
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(item.label),
                Text("$index"),
                Text("${item.age}"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Replace it with your real items request
Future<Pagination<RealEstate>> getFakeItems(
  int skip,
  CameraPosition cameraPosition,
) async {
  const imageUrl =
      "https://images.unsplash.com/photo-1582407947304-fd86f028f716?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2196&q=80";
  const items = [
    RealEstate(
      id: "1",
      imageUrl: imageUrl,
      location: LatLng(33.40321407949425, 44.37569438560405),
      label: "100\$",
      age: 10,
    ),
    RealEstate(
      id: "2",
      imageUrl: imageUrl,
      location: LatLng(33.43321407949425, 44.37569438560405),
      label: "140\$",
      age: 40,
    ),
    RealEstate(
      id: "3",
      imageUrl: imageUrl,
      location: LatLng(33.40321407949425, 44.39569438560405),
      label: "340\$",
      age: 15,
    ),
    RealEstate(
      id: "4",
      imageUrl: imageUrl,
      location: LatLng(33.45321407949425, 44.37569438560405),
      label: "10\$",
      age: 20,
    ),
    RealEstate(
      id: "5",
      imageUrl: imageUrl,
      location: LatLng(33.40321407949425, 44.37569438560405),
      label: "190\$",
      age: 3,
    ),
  ];
  return Future.delayed(const Duration(seconds: 2), () {
    return const Pagination(results: items, count: 50);
  });
}
