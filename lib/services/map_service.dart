import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

// TODO Add University related markers

//TODO When finished, add all to app_en.arb and app_tr.arb and apply here for localization

class MapService {
  final _campusCenter = LatLng(36.786659, 34.525297);
  final _controller = Completer<GoogleMapController>();
  bool _markersVisible = true;
  bool get markersVisible => _markersVisible;
  LatLng get campusCenter => _campusCenter;
  Set<Marker> _markers = {};

  CameraPosition get initialCameraPosition {
    return CameraPosition(
      target: _campusCenter,
      zoom: 15.5,
    );
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

  Set<Marker> getMarkers(BuildContext context) {
    final locations = getLocations(context);
    _markers = locations.map((location) {
      return Marker(
        markerId: MarkerId(location['name']),
        position: location['position'] as LatLng,
        infoWindow: InfoWindow(title: location['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        visible: _markersVisible,
      );
    }).toSet();
    return _markers;
  }

  void toggleMarkers() {
    _markersVisible = !_markersVisible;
    _markers = _markers.map((marker) {
      return marker.copyWith(visibleParam: _markersVisible);
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
        // await openAppSettings(); //TODO Check later
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
}
