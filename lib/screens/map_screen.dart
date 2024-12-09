import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meu_assistant/widgets/custom_expandable_fab.dart';
import 'package:meu_assistant/widgets/simpler_custom_loading.dart';
import 'package:get/get.dart';
import '../models/map_location.dart';
import '../services/map_service.dart';
import '../widgets/base_scaffold.dart';

//TODO Add a list somewhere to show all markers and their names and allow the user to click on them to center the map to that marker

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  static const String routeName = '/map';

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapService mapService = Get.put(MapService());
  String? mapStyle;
  late Future<bool> _locationPermissionFuture;
  final Set<Polyline> _polylines = {};
  final _searchController = TextEditingController();
  List<MapLocation> _searchResults = [];
  bool _isSearching = false;
  late AnimationController _animationController;

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
    _searchController.addListener(() => _onSearchChanged(_searchController.text));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    mapService.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchResults = mapService.getLocations(context).where((location) {
        return location.name.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  void _toggleSearchMode() {
    setState(() {
      if (_isSearching) {
        _animationController.reverse();
        _searchController.clear();
        _searchResults.clear();
      } else {
        _animationController.forward();
        _searchResults = mapService.getLocations(context);
      }
      _isSearching = !_isSearching;
    });
  }

  Widget _buildSearchInput() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 56.0, right: 8.0), // Adjust padding for drawer action
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search,
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildSearchSheet() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(25),
        ),
        color: _isSearching ? Theme.of(context).colorScheme.primary : null,
      ),
      height: _isSearching ? 250 : 0,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          if (_isSearching)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                        Icons.location_city,
                      ),
                      title: Text(
                        _searchResults[index].name,
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.pin_drop,
                        ),
                        onPressed: () {
                          // TODO: Implement the click functionality to target the pin
                        },
                      ),
                      onTap: () {
                        // TODO: Implement the click functionality to target the pin
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
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
        style: mapStyle, //TODO Uncomment this line after adding all the custom markers
      ),
    );
  }

  void _createRoute() async {
    try {
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
        await mapService.setCameraToRoute(); // Set camera to fit the route
      } else {
        // Handle the case where user location is not available
        return;
      }
    } catch (e) {
      log('Error creating route: $e');
      // Handle the error appropriately
    }
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      mapService.clearRoute();
    });
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarTitle: _isSearching ? null : AppLocalizations.of(context)!.mapScreenTitle,
      appBarActions: [
        if (_isSearching) _buildSearchInput(),
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: _toggleSearchMode,
        ),
      ],
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: FutureBuilder<bool>(
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
              )),
            ],
          ),
          _buildSearchSheet(),
        ],
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
                  : Icon(_polylines.isEmpty ? Icons.directions : Icons.clear),
              onPressed: mapService.isRouteLoading.value
                  ? null
                  : () {
                      if (_polylines.isEmpty) {
                        _createRoute();
                      } else {
                        _clearRoute();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
