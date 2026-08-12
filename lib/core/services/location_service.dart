import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isWithinGeofence(double targetLat, double targetLong, {double radiusInMeters = 100}) async {
    final position = await getCurrentLocation();
    if (position == null) return false;

    final double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetLat,
      targetLong,
    );

    return distance <= radiusInMeters;
  }
}
