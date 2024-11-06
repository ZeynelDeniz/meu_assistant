import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meu_assistant/widgets/custom_expandable_fab.dart';
import '../services/map_service.dart';
import '../widgets/base_scaffold.dart';

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
  late Future<bool> _locationPermissionFuture;

  @override
  void initState() {
    super.initState();
    _locationPermissionFuture = mapService.requestLocationPermission();
    mapService.loadMapStyle().then((style) {
      setState(() {
        mapStyle = style;
      });
    });
  }

  Widget _buildMap(bool locationEnabled) {
    return GoogleMap(
      myLocationEnabled: locationEnabled,
      myLocationButtonEnabled: locationEnabled,
      onLongPress: mapService.onLongPress,
      mapType: MapType.normal,
      initialCameraPosition: mapService.initialCameraPosition,
      onMapCreated: mapService.onMapCreated,
      markers: mapService.getMarkers(context),
      style: mapStyle, //TODO Uncomment this line after adding all the custom markers
    );
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarTitle: AppLocalizations.of(context)!.mapScreenTitle,
      body: FutureBuilder<bool>(
        future: _locationPermissionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          } else if (snapshot.hasError || !snapshot.hasData) {
            return _buildMap(false);
          } else {
            return _buildMap(snapshot.data!);
          }
        },
      ),
      fab: CustomExpandableFab(
        distance: 75,
        secondaryDistance: 50,
        children: [
          ActionButton(
            icon: Icon(
              mapService.markersVisible ? Icons.location_pin : Icons.location_off,
            ),
            onPressed: () {
              setState(() {
                mapService.toggleMarkers();
              });
            },
          ),
          ActionButton(
            icon: Icon(Icons.home),
            onPressed: () {
              mapService.moveToLocation(mapService.campusCenter, zoom: 15.5);
            },
          ),
          ActionButton(
            icon: const Icon(Icons.construction),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
