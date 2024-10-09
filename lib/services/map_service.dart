import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// TODO Add University related markers

//TODO When finished, add all to app_en.arb and app_tr.arb and apply here for localization

class MapService {
  static const LatLng campusCenter = LatLng(36.78605165340255, 34.52843719135306);
  final PopupController popupController = PopupController();

  List<Map<String, dynamic>> getLocations(BuildContext context) {
    return [
      {'name': AppLocalizations.of(context)!.loc_1, 'position': LatLng(36.784779, 34.526218)},
      {'name': 'Mühendislik Derslikleri A Blok', 'position': LatLng(36.786103, 34.525679)},
      {'name': 'Mühendislik Derslikleri B Blok', 'position': LatLng(36.786228, 34.526015)},
      {'name': 'Kütüphane', 'position': LatLng(36.783297, 34.527555)},
      {'name': 'Yabancı Diller Yüksekokulu', 'position': LatLng(36.783277, 34.528045)},
    ];
  }

  List<Marker> getMarkers(BuildContext context) {
    final locations = getLocations(context);
    return locations.map((location) {
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
  }
}
// class ExamplePopup extends StatelessWidget {
//   final Marker marker;

//   const ExamplePopup(this.marker, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Find the location corresponding to the marker

//     final location = locations.firstWhere(
//       (loc) => loc['position'] == marker.point,
//     );

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(location['name'] as String),
//       ),
//     );
//   }
// }
