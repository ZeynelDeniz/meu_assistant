import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

import '../services/map_service.dart';
import '../widgets/base_scaffold.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  static const String routeName = '/map';

  @override
  MapScreenState createState() => MapScreenState();
}

//TODO Add a button to toggle all markers

//TODO Add a button to center the map to the campus center and reset rotation and zoom

//TODO Add a list somewhere to show all markers and their names and allow the user to click on them to center the map to that marker

//TODO LATER: Add a button to show the user's location on the map

//TODO LATER: Create routing between user location and a selected marker

class MapScreenState extends State<MapScreen> {
  static final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarTitle: AppLocalizations.of(context)!.mapScreenTitle,
      body: Column(
        children: [
          Flexible(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onTap: (_, __) => popupController.hideAllPopups(),
                onLongPress: (tapPosition, point) {
                  log('Pressed location: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}');
                },
                initialCenter: campusCenter,
                initialZoom: 15,
                maxZoom: 20,
                minZoom: 3,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(markers: markers),
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    markers: markers,
                    popupController: popupController,
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) => ExamplePopup(marker),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
