import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  String _currentAddress = '';
  bool _isLoading = false;
  String _error = '';

  Position? get currentPosition => _currentPosition;
  String get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled.';
        notifyListeners();
        return false;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permissions are denied.';
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permissions are permanently denied.';
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      _error = 'Error checking location permission: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await getAddressFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error getting current location: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }
    } catch (e) {
      _error = 'Error getting address: $e';
      notifyListeners();
    }
  }

  Future<String> getAddressFromCoordinatesAsync(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  List<Map<String, dynamic>> getNearbyPets(
    List<Map<String, dynamic>> pets,
    double maxDistanceInMeters,
  ) {
    if (_currentPosition == null) return [];

    return pets.where((pet) {
      final petLat = pet['latitude'] as double? ?? 0.0;
      final petLon = pet['longitude'] as double? ?? 0.0;
      
      final distance = calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        petLat,
        petLon,
      );
      
      return distance <= maxDistanceInMeters;
    }).toList();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
} 