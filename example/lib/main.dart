import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:google_maps_pagination/google_maps_pagination.dart';
import 'package:google_maps_pagination/models/camera_event.dart';
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

  static final initialCameraPosition = MapCameraEvent(
    target: LatLng(33.31630340525106, 44.44362264328901),
    zoom: 16,
  );

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PageController _pageViewController =
      PageController(viewportFraction: 0.9);

  gmaps.GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PaginationMap<RealEstate>(
          initialCameraPosition: MyApp.initialCameraPosition,
          mapController: _mapController,
          initialHeight: 100,
          pageViewController: _pageViewController,
          setMapController: (value) {
            setState(() {
              _mapController = value;
            });
          },
          onSelectedItemChanged: (value) {},
          selectedItemId: "",
          onItemsChanged: getFakeItems,
          markerLabelFormatter: (value) => "$value USD",
          itemBuilder: (BuildContext context, RealEstate item, int index) {
            return ItemListTile(item: item, index: index);
          },
          controllerTheme: const MapPaginationControllerTheme(
            controllerColor: Color(0xFF007bff),
            backgroundColor: Color(0xFFFFDA85),
            textColor: Colors.black,
          ),
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
  MapCameraEvent cameraPosition,
) async {
  const imageUrl =
      "https://images.unsplash.com/photo-1582407947304-fd86f028f716?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2196&q=80";

  final items = List.generate(
    locations.length,
    (index) => RealEstate(
      id: "$index",
      label: "$index",
      age: index + 10,
      imageUrl: imageUrl,
      location: locations[index],
    ),
  );

  const limit = 25;
  if (kDebugMode) {
    print(skip * limit);
    print(skip * limit + limit);
  }
  return Future.delayed(const Duration(seconds: 2), () {
    return Pagination(
      results: items,
      count: items.length,
    );
  });
}

final locations = [
  LatLng(33.312865197724754, 44.44767520560694),
  LatLng(33.31707238155747, 44.44244454008099),
  LatLng(33.30864570869721, 44.44497774410984),
  LatLng(33.31249267737816, 44.44298493761739),
  LatLng(33.30890204655171, 44.44678962317027),
  LatLng(33.31164201046029, 44.447308889788076),
  LatLng(33.31077089994535, 44.448629257089344),
  LatLng(33.31183616512001, 44.44432179908886),
  LatLng(33.310768052593154, 44.44544432081772),
  LatLng(33.31375252444314, 44.448933404015904),
  LatLng(33.31437761763656, 44.44830795294981),
  LatLng(33.31793298896757, 44.44316574375583),
  LatLng(33.31079895820305, 44.4422574325504),
  LatLng(33.31222350462642, 44.44635710393903),
  LatLng(33.31012556827874, 44.44286334349959),
  LatLng(33.31662848687807, 44.444408079815325),
  LatLng(33.31604213405665, 44.44302218920426),
  LatLng(33.30942362710462, 44.44942191465364),
  LatLng(33.31962545373452, 44.44423181994462),
  LatLng(33.31949848637002, 44.44759728043064),
  LatLng(33.31885925942626, 44.442394501239384),
  LatLng(33.31980179630068, 44.44585622633498),
  LatLng(33.30921544039861, 44.45046979848006),
  LatLng(33.30892764270406, 44.44617113123445),
  LatLng(33.30843497389466, 44.4481833246162),
  LatLng(33.31241066875523, 44.448099766560624),
  LatLng(33.31452013571979, 44.44488654324873),
  LatLng(33.31514381183993, 44.444462956341816),
  LatLng(33.31315878324101, 44.44710027401202),
  LatLng(33.31745034684948, 44.44226671831505),
  LatLng(33.314551922984364, 44.44629749841645),
  LatLng(33.31949848637002, 44.44759728043064),
  LatLng(33.31885925942626, 44.442394501239384),
  LatLng(33.31980179630068, 44.44585622633498),
  LatLng(33.30921544039861, 44.45046979848006),
  LatLng(33.30892764270406, 44.44617113123445),
  LatLng(33.30843497389466, 44.4481833246162),
  LatLng(33.31241066875523, 44.448099766560624),
  LatLng(33.31452013571979, 44.44488654324873),
  LatLng(33.31514381183993, 44.444462956341816),
  LatLng(33.31315878324101, 44.44710027401202),
  LatLng(33.31745034684948, 44.44226671831505),
  LatLng(33.314551922984364, 44.44629749841645),
  LatLng(33.31949848637002, 44.44759728043064),
  LatLng(33.31885925942626, 44.442394501239384),
  LatLng(33.31980179630068, 44.44585622633498),
  LatLng(33.30921544039861, 44.45046979848006),
  LatLng(33.30892764270406, 44.44617113123445),
  LatLng(33.30843497389466, 44.4481833246162),
  LatLng(33.31241066875523, 44.448099766560624),
  LatLng(33.31452013571979, 44.44488654324873),
  LatLng(33.31514381183993, 44.444462956341816),
  LatLng(33.31315878324101, 44.44710027401202),
  LatLng(33.31745034684948, 44.44226671831505),
  LatLng(33.314551922984364, 44.44629749841645),
  LatLng(33.31315878324101, 44.44710027401202),
  LatLng(33.31745034684948, 44.44226671831505),
  LatLng(33.314551922984364, 44.44629749841645),
];
