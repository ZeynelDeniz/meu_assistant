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

// TODO DENİZ Add University related markers

//TODO DENİZ When finished, add all to app_en.arb and app_tr.arb and apply here for localization

//TODO When a route is created, make other markers invisible

//TODO When a route is created, add a button to clear the route

//TODO Add University ring routes

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
        markerId: MarkerId(location['name']),
        position: location['position'] as LatLng,
        infoWindow: InfoWindow(title: location['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        visible: _markersVisible.value,
        onTap: () {
          lastSelectedMarker.value = location['position'] as LatLng;
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

  List<Map<String, dynamic>> getLocations(BuildContext context) {
    return [
      {
        'name': AppLocalizations.of(context)!.marker_loc_1,
        'position': LatLng(36.784779, 34.526218)
      },
      {'name': 'Mühendislik Derslikleri A Blok', 'position': LatLng(36.786103, 34.525679)},
      {'name': 'Mühendislik Derslikleri B Blok', 'position': LatLng(36.786228, 34.526015)},
      {'name': 'Kütüphane', 'position': LatLng(36.783297, 34.527555)},
      {'name': 'Yabancı Diller Yüksekokulu', 'position': LatLng(36.783277, 34.528045)},
    ];
  }

  Future<void> getRoute(LatLng start, LatLng end) async {
    isRouteLoading.value = true;
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
      _routePoints = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
    }
    isRouteLoading.value = false;
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
}
