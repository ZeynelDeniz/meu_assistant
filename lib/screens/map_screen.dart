import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meu_assistant/widgets/simple_custom_loading.dart';
import 'package:get/get.dart';
import '../models/map_location.dart';
import '../services/map_service.dart';
import '../widgets/base_scaffold.dart';
import '../services/map_data.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
  });
  static const String routeName = '/map';

  @override
  MapScreenState createState() => MapScreenState();
}

//TODO After changing language, the search results are not updated, which causes the app to crash when selecting a location

class MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapService mapService = Get.put(MapService());
  String? mapStyle;
  late Future<bool> _locationPermissionFuture;
  final Set<Polyline> _polylines = {};
  final Set<Polyline> _staticPolylines = {};
  final _searchController = TextEditingController();
  List<MapLocation> _searchResults = [];
  bool _isSearching = false;
  late AnimationController _animationController;
  int? initialLocationId;

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
      if (mapService.getRingStopMarkers(context).any((marker) => marker.position == position)) {
        final location = getRingStops(context).firstWhere((stop) => stop.position == position);
        _showBottomSheet(location);
      }
    };
    _searchController.addListener(() => _onSearchChanged(_searchController.text));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    mapService.toggleRingRoute();
    _staticPolylines.add(Polyline(
      polylineId: PolylineId('staticRoute'),
      points: ringRoutePoints,
      color: Colors.red,
      width: 5,
    ));

    // Get the initialLocationId from arguments
    initialLocationId = Get.arguments?['initialLocationId'];
    log('Initial Location ID: $initialLocationId');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialLocationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MapLocation? location = getLocations(context).firstWhere(
          (loc) => loc?.id == initialLocationId,
          orElse: () => null,
        );
        if (location != null) {
          mapService.selectPin(location);
          mapService.moveToLocation(location.position, zoom: 17);
        }
      });
    }
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
      _searchResults = getLocations(context)
          .where((location) {
            return location?.name.toLowerCase().contains(value.toLowerCase()) ?? false;
          })
          .whereType<MapLocation>() // Filter out null values
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
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
        _searchResults = getLocations(context).whereType<MapLocation>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      }
      _isSearching = !_isSearching;
    });
  }

  Future<void> _createRoute() async {
    try {
      if (mapService.lastSelectedMarker.value == null) {
        // Handle the case where no marker is selected
        log('BUG: No marker selected');
        return;
      }

      LatLng? userLocation = await mapService.getUserLocation();
      log('User location: $userLocation');
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

  void _showBottomSheet(MapLocation location) {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 300,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                location.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Ring Saatleri',
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ringHours[location.name]?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(ringHours[location.name]?[index] ?? ''),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
          Obx(() => _buildMapButtons()),
        ],
      ),
    );
  }

  Widget _buildMapButtons() {
    return Positioned(
      bottom: 36,
      left: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'toggleStaticRoute',
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              mapService.staticRouteVisible ? Icons.directions_bus : Icons.directions_bus_outlined,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: () {
              setState(() {
                mapService.toggleRingRoute();
              });
            },
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'createOrClearRoute',
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: mapService.isRouteLoading.value ||
                    (mapService.lastSelectedMarker.value == null && _polylines.isEmpty)
                ? null
                : () {
                    if (_polylines.isEmpty) {
                      _createRoute();
                    } else {
                      _clearRoute();
                    }
                  },
            child: mapService.isRouteLoading.value
                ? SizedBox(
                    width: 30,
                    height: 30,
                    child: SimpleCustomLoadingIndicator(
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.blue,
                    ),
                  )
                : Icon(
                    _polylines.isEmpty ? Icons.directions : Icons.clear,
                    color: mapService.lastSelectedMarker.value == null && _polylines.isEmpty
                        ? Colors.grey
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'toggleMarkers',
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              mapService.markersVisible ? Icons.location_pin : Icons.location_off,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: () {
              mapService.toggleMarkers();
            },
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'moveToLocation',
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.home,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: () {
              mapService.moveToLocation(mapService.campusCenter, zoom: 15.5);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildSearchInput() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 56.0, right: 8.0, top: 4, bottom: 4),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search,
            hintStyle: TextStyle(color: Colors.grey),
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
                          Icons.directions,
                        ),
                        onPressed: () async {
                          mapService.selectPin(_searchResults[index]);
                          _toggleSearchMode();

                          await _createRoute();
                        },
                      ),
                      onTap: () {
                        mapService.selectPin(_searchResults[index]);
                        mapService.moveToLocation(_searchResults[index].position, zoom: 17);
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
        buildingsEnabled: false,
        initialCameraPosition: mapService.initialCameraPosition,
        onMapCreated: mapService.onMapCreated,
        markers: {
          ...mapService.getMarkers(context),
          ...mapService.getRingStopMarkers(context),
        },
        polylines: {
          ..._polylines,
          if (mapService.staticRouteVisible) ..._staticPolylines,
        },
        mapToolbarEnabled: false,
        style: mapStyle,
      ),
    );
  }
}
