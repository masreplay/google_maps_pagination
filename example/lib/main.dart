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

  @override
  final LatLng location;

  RealEstate({
    required super.id,
    required super.label,
    required this.age,
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
  final PageController _pageController = PageController();

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
          setMapController: (value) {
            setState(() {
              _mapController = value;
            });
          },
          pageViewController: _pageController,
          onItemsChanged: (skip, cameraPosition) {
            return getFakeItems(skip, cameraPosition);
          },
          markerLabelFormatter: (value) {
            return "$value USD";
          },
          selectedItemId: _selectedItemId,
          onSelectedItemChanged: (value) {
            setState(() {
              _selectedItemId = value;
            });
          },
          pageViewItemBuilder:
              (BuildContext context, RealEstate item, int index) {
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
          Text("$index"),
          Text(item.label),
          Text("${item.age}"),
        ],
      ),
    );
  }
}

// Replace it with your real items request
Future<Pagination<RealEstate>> getFakeItems(
    int skip, CameraPosition cameraPosition) async {
  final items = [
    RealEstate(
      id: "1",
      location: const LatLng(33.40321407949425, 44.37569438560405),
      label: "100\$",
      age: 10,
    ),
    RealEstate(
      id: "2",
      location: const LatLng(33.40321407949425, 44.37569438560405),
      label: "140\$",
      age: 40,
    ),
    RealEstate(
      id: "3",
      location: const LatLng(33.40321407949425, 44.37569438560405),
      label: "340\$",
      age: 15,
    ),
    RealEstate(
      id: "4",
      location: const LatLng(33.40321407949425, 44.37569438560405),
      label: "10\$",
      age: 20,
    ),
    RealEstate(
      id: "5",
      location: const LatLng(33.40321407949425, 44.37569438560405),
      label: "190\$",
      age: 3,
    ),
  ];
  return Future.delayed(const Duration(seconds: 2), () {
    return Pagination(results: items, count: 100);
  });
}
