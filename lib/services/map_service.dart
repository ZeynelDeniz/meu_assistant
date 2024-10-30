import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// TODO Add University related markers

//TODO When finished, add all to app_en.arb and app_tr.arb and apply here for localization

class MapService {
  static LatLng campusCenter = LatLng(36.786659, 34.525297);
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  CameraPosition get initialCameraPosition {
    return CameraPosition(
      target: campusCenter,
      zoom: 15.5,
    );
  }

  List<Map<String, dynamic>> getLocations(BuildContext context) {
    return [
      {'name': AppLocalizations.of(context)!.loc_1, 'position': LatLng(36.784779, 34.526218)},
      {'name': 'Mühendislik Derslikleri A Blok', 'position': LatLng(36.786103, 34.525679)},
      {'name': 'Mühendislik Derslikleri B Blok', 'position': LatLng(36.786228, 34.526015)},
      {'name': 'Kütüphane', 'position': LatLng(36.783297, 34.527555)},
      {'name': 'Yabancı Diller Yüksekokulu', 'position': LatLng(36.783277, 34.528045)},
    ];
  }

  Set<Marker> getMarkers(BuildContext context) {
    final locations = getLocations(context);
    return locations.map((location) {
      return Marker(
        markerId: MarkerId(location['name']),
        position: location['position'] as LatLng,
        infoWindow: InfoWindow(title: location['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }).toSet();
  }

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void onLongPress(LatLng position) {
    log('${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}');
  }

  Future<void> moveToLocation(LatLng location) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(location));
  }

  Future<String> loadMapStyle() async {
    return await rootBundle.loadString('assets/map_style.json');
  }
}
