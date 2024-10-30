import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/map_service.dart';
import '../widgets/base_scaffold.dart';

//TODO Add a button to toggle all markers

//TODO Add a button to center the map to the campus center and reset rotation and zoom

//TODO Add a list somewhere to show all markers and their names and allow the user to click on them to center the map to that marker

//TODO LATER: Add a button to show the user's location on the map

//TODO LATER: Create routing between user location and a selected marker

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  static const String routeName = '/map';

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final MapService mapService = MapService();
  String? mapStyle;

  @override
  void initState() {
    super.initState();
    mapService.loadMapStyle().then((style) {
      setState(() {
        mapStyle = style;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarTitle: AppLocalizations.of(context)!.mapScreenTitle,
      body: GoogleMap(
        onLongPress: mapService.onLongPress,
        mapType: MapType.normal,
        initialCameraPosition: mapService.initialCameraPosition,
        onMapCreated: mapService.onMapCreated,
        markers: mapService.getMarkers(context),
        // style: mapStyle, //TODO Uncomment this line after adding all the custom markers
      ),
    );
  }
}
