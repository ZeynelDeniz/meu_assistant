import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocation {
  final String name;
  final LatLng position;
  final String? phone;
  final String? email;

  MapLocation({
    required this.name,
    required this.position,
    this.phone,
    this.email,
  });
}
