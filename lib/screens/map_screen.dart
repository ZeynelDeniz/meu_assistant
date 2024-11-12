import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meu_assistant/widgets/custom_expandable_fab.dart';
import 'package:meu_assistant/widgets/simpler_custom_loading.dart';
import 'package:get/get.dart';
import '../services/map_service.dart';
import '../widgets/base_scaffold.dart';

//TODO Add a list somewhere to show all markers and their names and allow the user to click on them to center the map to that marker

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  static const String routeName = '/map';

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final MapService mapService = Get.put(MapService());
  String? mapStyle;
  late Future<bool> _locationPermissionFuture;
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _locationPermissionFuture = mapService.requestLocationPermission();
    mapService.loadMapStyle().then((style) {
      setState(() {
        mapStyle = style;
      });
    });
    mapService.onMarkerTapped = (LatLng position) {
      log('Marker tapped at: ${position.latitude}, ${position.longitude}');
    };
  }

  Widget _buildMap(bool locationEnabled) {
    return Obx(
      () => GoogleMap(
        myLocationEnabled: locationEnabled,
        myLocationButtonEnabled: locationEnabled,
        onLongPress: mapService.onLongPress,
        onTap: (LatLng position) {
          mapService.clearLastSelectedMarker();
        },
        mapType: MapType.normal,
        initialCameraPosition: mapService.initialCameraPosition,
        onMapCreated: mapService.onMapCreated,
        markers: mapService.getMarkers(context),
        polylines: _polylines,
        mapToolbarEnabled: false,
        // style: mapStyle, //TODO Uncomment this line after adding all the custom markers
      ),
    );
  }

  void _createRoute() async {
    if (mapService.lastSelectedMarker.value == null) {
      // Handle the case where no marker is selected
      return;
    }

    LatLng? userLocation = await mapService.getUserLocation();
    if (userLocation != null) {
      LatLng targetLocation = mapService.lastSelectedMarker.value!;
      await mapService.getRoute(userLocation, targetLocation);
      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: mapService.routePoints,
          color: Colors.blue,
          width: 5,
        ));
      });
    } else {
      // Handle the case where user location is not available,
      return;
    }
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
      fab: Obx(
        () => CustomExpandableFab(
          distance: 75,
          secondaryDistance: 50,
          children: [
            ActionButton(
              icon: Icon(
                mapService.markersVisible ? Icons.location_pin : Icons.location_off,
              ),
              onPressed: () {
                mapService.toggleMarkers();
              },
            ),
            ActionButton(
              icon: Icon(Icons.home),
              onPressed: () {
                mapService.moveToLocation(mapService.campusCenter, zoom: 15.5);
              },
            ),
            ActionButton(
              icon: mapService.isRouteLoading.value
                  ? SizedBox(
                      width: 30,
                      height: 30,
                      child: SimplerCustomLoader(),
                    )
                  : Icon(Icons.directions),
              onPressed:
                  mapService.isRouteLoading.value || mapService.lastSelectedMarker.value == null
                      ? null
                      : _createRoute,
            ),
          ],
        ),
      ),
    );
  }
}
