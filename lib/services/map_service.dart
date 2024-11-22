import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:get/get.dart';

import 'package:meu_assistant/constants/api_info.dart';
import 'package:meu_assistant/models/map_location.dart';

// TODO DENİZ Add University related markers

//TODO DENİZ When finished, add all to app_en.arb and app_tr.arb and apply here for localization

//TODO When a route is created, make other markers invisible

//TODO When a route is created, add a button to clear the route

//TODO DENİZ Find University ring routes

class MapService extends GetxController {
  final _controller = Completer<GoogleMapController>();
  final _campusCenter = LatLng(36.786659, 34.525297);
  LatLng get campusCenter => _campusCenter;
  final _markersVisible = true.obs;
  bool get markersVisible => _markersVisible.value;
  Set<Marker> _markers = {};
  Function(LatLng)? onMarkerTapped;
  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;
  final lastSelectedMarker = Rx<LatLng?>(null);
  var isRouteLoading = false.obs;

  CameraPosition get initialCameraPosition {
    return CameraPosition(
      target: _campusCenter,
      zoom: 15.5,
    );
  }

  Set<Marker> getMarkers(BuildContext context) {
    final locations = getLocations(context);
    _markers = locations.map((location) {
      return Marker(
        markerId: MarkerId(location.name),
        position: location.position,
        infoWindow: InfoWindow(title: location.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        visible: _markersVisible.value,
        onTap: () {
          lastSelectedMarker.value = location.position;
          if (onMarkerTapped != null) {
            onMarkerTapped!(lastSelectedMarker.value!);
          }
        },
      );
    }).toSet();
    return _markers;
  }

  void toggleMarkers() {
    _markersVisible.value = !_markersVisible.value;
    _markers = _markers.map((marker) {
      return marker.copyWith(visibleParam: _markersVisible.value);
    }).toSet();
  }

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void onLongPress(LatLng position) {
    log('${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}');
  }

  Future<void> moveToLocation(LatLng location, {double? zoom}) async {
    final GoogleMapController controller = await _controller.future;
    if (zoom != null) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(location, zoom));
    } else {
      controller.animateCamera(CameraUpdate.newLatLng(location));
    }
  }

  Future<String> loadMapStyle() async {
    return await rootBundle.loadString('assets/map_style.json');
  }

  Future<bool> requestLocationPermission() async {
    try {
      var status = await Permission.locationWhenInUse.status;
      if (status.isDenied) {
        status = await Permission.locationWhenInUse.request();
      }

      if (status.isPermanentlyDenied) {
        log('Location permission denied forever');
        return false;
      }

      return status.isGranted;
    } on PlatformException catch (e) {
      log('Location permission error: $e');
      return false;
    } catch (e) {
      log('Location permission error: $e');
      return false;
    }
  }

  Future<void> getRoute(LatLng start, LatLng end) async {
    isRouteLoading.value = true;
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleMapsApiKey,
        request: PolylineRequest(
          origin: PointLatLng(start.latitude, start.longitude),
          destination: PointLatLng(end.latitude, end.longitude),
          mode: TravelMode.walking,
        ),
      );

      if (result.points.isNotEmpty) {
        _routePoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      } else {
        log('No route points found');
      }
    } catch (e) {
      log('Error getting route: $e');
    } finally {
      isRouteLoading.value = false;
    }
  }

  Future<LatLng?> getUserLocation() async {
    try {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          log('Location service is disabled.');
          return null;
        }
      }

      var status = await Permission.locationWhenInUse.status;
      if (status.isDenied) {
        return null;
      }

      LocationData locationData = await location.getLocation();
      return LatLng(locationData.latitude!, locationData.longitude!);
    } on PlatformException catch (e) {
      log('Location error: $e');
      return null;
    } catch (e) {
      log('Location error: $e');
      return null;
    }
  }

  void clearLastSelectedMarker() {
    lastSelectedMarker.value = null;
  }

//TODO Some names are not displayed fully, Needs to be fixed
  List<MapLocation> getLocations(BuildContext context) {
    return [
      MapLocation(
          name: AppLocalizations.of(context)!.loc_1,
          position: LatLng(36.785369, 34.526026),
          email: "muhendislik@mersin.edu.tr",
          phones: ["324 361 00 33", "324 361 00 01"]),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_2,
        position: LatLng(36.786103, 34.525679),
        //no email and phone
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_3,
        position: LatLng(36.786228, 34.526015),
        //no email and phone
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_4,
        position: LatLng(36.783297, 34.527555),
        phones: ["324 361 0018", "324 361 00 01", "324 361 00 17"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_5,
        position: LatLng(36.783277, 34.528045),
        email: "ydilleryo@mersin.edu.tr",
        phones: ["324 361 00 38", "324 361 00 01", "324 361 02 43"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_6,
        position: LatLng(36.782376, 34.528113),
        email: "teknikbilimler@mersin.edu.tr",
        phones: ["324 361 00 38", "324 361 00 01", "324 361 00 43"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_7,
        position: LatLng(36.783463, 34.528003),
        email: "",
        phones: ["324 361 00 01", "324 361 03 43"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_8,
        position: LatLng(36.783488, 34.528069),
        email: "",
        phones: ["324 361 00 01"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_9,
        position: LatLng(36.783584, 34.526420),
        email: "meuoidb@mersin.edu.tr",
        phones: ["324 361 06 48", "324 361 01 00 "],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_10,
        position: LatLng(36.783482, 34.526383),
        email: "bidb@mersin.edu.tr",
        phones: ["324 361 00 01", "324 361 06 24", "324 361 04 79"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_11,
        position: LatLng(36.784709, 34.526651),
        email: "iktisat@mersin.edu.tr",
        phones: ["324 361 00 01", "324 361 00 56"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_12,
        position: LatLng(36.784931, 34.527243),
        email: "konservatuvar@mersin.edu.tr",
        phones: ["324 361 00 01", "324 361 00 29"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_13,
        position: LatLng(36.786228, 34.525563),
        email: "basin@mersin.edu.tr",
        phones: ["324 361 00 01", "324 361 00 64", "324 361 00 63"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_14,
        position: LatLng(36.785967, 34.525493),
        email: "baum@mersin.edu.tr",
        phones: ["324 361 00 01"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_15,
        position: LatLng(36.786951, 34.525335),
        //no email and phone
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_16,
        position: LatLng(36.786666, 34.524407),
        //no email and phone
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_17,
        position: LatLng(36.787275, 34.526067),
        //no email and phone
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_18,
        position: LatLng(36.788089, 34.523792),
        email: "saglikyo@mersin.edu.tr",
        phones: ["324 361 00 01", "324 361 05 81", "324 361 05 71"],
      ),
      MapLocation(
        name: AppLocalizations.of(context)!.loc_19,
        position: LatLng(36.788243, 34.524717),
        email: "insanvetoplum@mersin.edu.tr",
        phones: ["324 361 00 01"],
      ),
    ];
  }
}
