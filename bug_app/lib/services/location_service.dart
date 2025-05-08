import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("Location services are disabled.");
    return null; // Location services are disabled
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return null; // Permissions are denied permanently
    }
  }

  // Get the current position with desired accuracy
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // Request high accuracy
    );
    return position;
  } catch (e) {
    print("Error getting location: $e");
    return null; // Return null if there's an error
  }
}

// Call this function to initialize location
void initializeLocation() async {
  Position? position = await getCurrentLocation();
  if (position != null) {
    print("User location: ${position.latitude}, ${position.longitude}");
  } else {
    print("Failed to get the user's location.");
  }
}
