import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/restaurant_model.dart';
import 'package:provider/provider.dart';
import '../controllers/restaurant_controller.dart';

class MapView extends StatefulWidget {
  final Restaurant? selectedRestaurant;

  const MapView({Key? key, this.selectedRestaurant}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurants();
    });
  }

  Future<void> _loadRestaurants() async {
    final controller = context.read<RestaurantController>();
    await controller.loadRestaurants();
    _updateMarkers();
  }

  void _updateMarkers() {
    final controller = context.read<RestaurantController>();
    final restaurants = controller.restaurants;

    setState(() {
      _markers = restaurants.map((restaurant) {
        return Marker(
          point: LatLng(restaurant.latitude, restaurant.longitude),
          child: Tooltip(
            message: "${restaurant.name}\n${restaurant.cuisine.join(', ')}",
            child: const Icon(Icons.location_on, color: Colors.red),
          ),
        );
      }).toList();

      // If a restaurant is selected, move map to its location
      if (widget.selectedRestaurant != null) {
        _mapController.move(
          LatLng(
            widget.selectedRestaurant!.latitude,
            widget.selectedRestaurant!.longitude,
          ),
          14,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RestaurantController>();
    final currentLocation = controller.currentLocation;

    if (currentLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(currentLocation.latitude, currentLocation.longitude),
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.appveg_flutter',
        ),
        MarkerLayer(
          markers: _markers,
        ),
        // Add current location marker
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(currentLocation.latitude, currentLocation.longitude),
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
