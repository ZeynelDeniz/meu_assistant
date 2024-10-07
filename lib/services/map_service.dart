import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';

const campusCenter = LatLng(36.78605165340255, 34.52843719135306);
final PopupController popupController = PopupController();

// TODO Add University related markers

//TODO When finished, add all to app_en.arb and app_tr.arb and apply here for localization

var locations = [
  {'name': 'Mühendislik Binası', 'position': LatLng(36.784779, 34.526218)},
  {'name': 'Mühendislik Derslikleri A Blok', 'position': LatLng(36.786103, 34.525679)},
  {'name': 'Mühendislik Derslikleri B Blok', 'position': LatLng(36.786228, 34.526015)},
];

// Updated markers to use new Marker constructor
var markers = locations.map((location) {
  return Marker(
    key: UniqueKey(),
    width: 30,
    height: 30,
    point: location['position'] as LatLng,
    child: GestureDetector(
      onTap: () {
        popupController.hideAllPopups();
        popupController.togglePopup(Marker(
          point: location['position'] as LatLng,
          child: const SizedBox.shrink(),
        ));
      },
      child: Icon(Icons.location_pin, color: Colors.blue, size: 30),
    ),
  );
}).toList();

class ExamplePopup extends StatelessWidget {
  final Marker marker;

  const ExamplePopup(this.marker, {super.key});

  @override
  Widget build(BuildContext context) {
    // Find the location corresponding to the marker

    final location = locations.firstWhere(
      (loc) => loc['position'] == marker.point,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(location['name'] as String),
      ),
    );
  }
}
