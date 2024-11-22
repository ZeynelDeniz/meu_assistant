import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocation {
  final String name;
  final LatLng position;
  final List<String?>? phones;
  final String? email;

  MapLocation({
    required this.name,
    required this.position,
    this.phones,
    this.email,
  });
}
