import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocation {
  final int id;
  final String name;
  final LatLng position;
  final List<String?>? phones;
  final String? email;

  MapLocation({
    required this.id,
    required this.name,
    required this.position,
    this.phones,
    this.email,
  });
}
