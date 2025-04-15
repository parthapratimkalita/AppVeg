import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class RestaurantController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  
  List<Restaurant> _restaurants = [];
  List<Restaurant> _favorites = [];
  Restaurant? _selectedRestaurant;
  bool _isLoading = false;
  Position? _currentLocation;

  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get favorites => _favorites;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  Position? get currentLocation => _currentLocation;

  Future<void> loadRestaurants() async {
    _isLoading = true;
    notifyListeners();

    try {
      _restaurants = await _apiService.getRestaurants();
      await _updateCurrentLocation();
      _sortRestaurantsByDistance();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _apiService.getFavorites();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectRestaurant(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedRestaurant = await _apiService.getRestaurantById(id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String restaurantId) async {
    final restaurant = _restaurants.firstWhere((r) => r.id == restaurantId);
    final isFavorite = restaurant.isFavorite;

    // Optimistically update UI
    restaurant.isFavorite = !isFavorite;
    notifyListeners();

    try {
      bool success;
      if (isFavorite) {
        success = await _apiService.removeFromFavorites(restaurantId);
      } else {
        success = await _apiService.addToFavorites(restaurantId);
      }

      if (!success) {
        // Revert if the operation failed
        restaurant.isFavorite = isFavorite;
        notifyListeners();
      } else {
        await loadFavorites(); // Refresh favorites list
      }
    } catch (e) {
      // Revert on error
      restaurant.isFavorite = isFavorite;
      notifyListeners();
    }
  }

  Future<void> _updateCurrentLocation() async {
    _currentLocation = await _locationService.getCurrentLocation();
    if (_currentLocation != null) {
      _sortRestaurantsByDistance();
    }
  }

  void _sortRestaurantsByDistance() {
    if (_currentLocation == null) return;

    _restaurants.sort((a, b) {
      final distanceA = _locationService.calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = _locationService.calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        b.latitude,
        b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });
    notifyListeners();
  }

  double? getDistanceToRestaurant(Restaurant restaurant) {
    if (_currentLocation == null) return null;

    return _locationService.calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      restaurant.latitude,
      restaurant.longitude,
    );
  }
}
