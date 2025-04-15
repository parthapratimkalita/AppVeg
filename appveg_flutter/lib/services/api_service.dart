import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant_model.dart';
import '../models/user_model.dart';
import 'dart:io';

class ApiService {
  // Authentication server running on port 8085
  static const String authBaseUrl = 'http://localhost:8085';
  // Restaurant server running on port 8000
  static const String restaurantBaseUrl = 'http://localhost:8000/api';
  static const String tokenKey = 'auth_token';
  
  String getGoBackendBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8085';
    } else {
      return 'http://localhost:8085';
    }
  }

  String getPythonBackendBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Authentication
  Future<User?> login(String email, String password) async {
    try {
      print('Attempting login with email: $email');
      final response = await http.post(
        Uri.parse('${getGoBackendBaseUrl()}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);
        return User.fromJson({
          'id': data['user_id'],
          'email': email,
          'username': email,
          'name': data['username'],
          'created_at': DateTime.now().toIso8601String(),
          'favorites': [],
        });
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Login error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<User?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${getGoBackendBaseUrl()}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      print('Registration response body: ${response.body}');
      print('Registration failed with status: ${response.statusCode}');
      print('Error response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _saveToken(data['token']);
          return User.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _removeToken();
  }

  // Restaurants
  Future<List<Restaurant>> getRestaurants({double? latitude, double? longitude, int radius = 5000}) async {
    try {
      final url = Uri.parse('${getPythonBackendBaseUrl()}/api/restaurants/nearby')
          .replace(queryParameters: {
            if (latitude != null) 'latitude': latitude.toString(),
            if (longitude != null) 'longitude': longitude.toString(),
            'radius': radius.toString(),
          });
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Restaurant.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get restaurants error: $e');
      return [];
    }
  }

  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final response = await http.get(Uri.parse('${getPythonBackendBaseUrl()}/api/restaurants/$id'));
      if (response.statusCode == 200) {
        return Restaurant.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Get restaurant by id error: $e');
      return null;
    }
  }

  // User
  Future<User?> getCurrentUser() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${getGoBackendBaseUrl()}/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  // Favorites
  Future<bool> addToFavorites(String restaurantId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${getPythonBackendBaseUrl()}/api/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'restaurant_id': restaurantId,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Add to favorites error: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(String restaurantId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${getPythonBackendBaseUrl()}/api/favorites/$restaurantId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Remove from favorites error: $e');
      return false;
    }
  }

  Future<List<Restaurant>> getFavorites() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${getPythonBackendBaseUrl()}/api/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Restaurant.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get favorites error: $e');
      return [];
    }
  }
}
