import 'dart:async';
import 'dart:math';

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
    target: LatLng(33.31630340525106, 44.44362264328901),
    zoom: 16,
  );

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PageController _pageViewController =
      PageController(viewportFraction: 0.9);

  GoogleMapController? _mapController;

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
  CameraPosition cameraPosition,
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
  print(skip * limit);
  print(skip * limit + limit);
  return Future.delayed(const Duration(seconds: 2), () {
    return Pagination(
      results: items.sublist(skip * 2, skip + (limit * 2)).toList(),
      count: items.length,
    );
  });
}

const locations = [
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
  LatLng(33.31832259776698, 44.44747827731388),
  LatLng(33.31036375235625, 44.44228478584306),
  LatLng(33.313190315063146, 44.44708194318101),
  LatLng(33.30929198840662, 44.44346501120198),
  LatLng(33.31569827781644, 44.443050117073426),
  LatLng(33.31058857019138, 44.44378830531614),
  LatLng(33.313946233669256, 44.44825171804552),
  LatLng(33.310337746569374, 44.45073302579741),
  LatLng(33.31343357405178, 44.44725056583262),
  LatLng(33.30930039071833, 44.4490048136067),
  LatLng(33.318453554156875, 44.4428621442169),
  LatLng(33.311918631315166, 44.44288219069107),
  LatLng(33.311345853497194, 44.442186544097176),
  LatLng(33.31521032216746, 44.443066251784444),
  LatLng(33.317293900849606, 44.44778526609077),
  LatLng(33.31961289152489, 44.445447063175806),
  LatLng(33.315095131022, 44.44644141292296),
  LatLng(33.3177784792776, 44.44379214049447),
  LatLng(33.30887279004097, 44.443649649107364),
  LatLng(33.315807338838766, 44.4472169268825),
  LatLng(33.30658071516725, 44.450459321318526),
  LatLng(33.31843250181038, 44.44443885150069),
  LatLng(33.30830774431578, 44.443839322032105),
  LatLng(33.316736774977734, 44.448202664323354),
  LatLng(33.31526243240751, 44.443844270944815),
  LatLng(33.31085452977859, 44.448681357543876),
  LatLng(33.307000297735165, 44.450970573882934),
  LatLng(33.31405898429324, 44.44948892132435),
  LatLng(33.31134477364262, 44.44720940464219),
  LatLng(33.3066059648403, 44.449840878819685),
  LatLng(33.30965824890842, 44.44961522220597),
  LatLng(33.317622529501996, 44.445368949262146),
  LatLng(33.319568382992294, 44.44358720634655),
  LatLng(33.315397957856376, 44.444511788110724),
  LatLng(33.30833905600766, 44.44980748849985),
  LatLng(33.314388924572405, 44.445070827610756),
  LatLng(33.31700577023592, 44.44911760983013),
  LatLng(33.31027945007129, 44.44220163511393),
  LatLng(33.309446356336736, 44.44457236403656),
  LatLng(33.31205554025111, 44.443163843060354),
  LatLng(33.306551524920295, 44.45061058553308),
  LatLng(33.30999299129531, 44.445006651569955),
  LatLng(33.31630340525106, 44.44362264328901)
];
