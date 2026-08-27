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
      // Attempt to get high accuracy position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // If accuracy is poor (e.g., > 50 meters), try one more time to get a better fix
      if (position.accuracy > 50) {
        await Future.delayed(const Duration(milliseconds: 500));
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 10),
          ),
        );
      }
      
      return position;
    } catch (e) {
      // Fallback to last known position if current fails
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
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

  static double getDistance(double startLat, double startLong, double endLat, double endLong) {
    return Geolocator.distanceBetween(startLat, startLong, endLat, endLong);
  }
}
