import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/restaurant_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/restaurant_model.dart';
import 'map_view.dart';

class RestaurantDetailView extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailView({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantController>().selectRestaurant(widget.restaurantId);
    });
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    await _launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RestaurantController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final restaurant = controller.selectedRestaurant;
          if (restaurant == null) {
            return const Center(child: Text('Restaurant not found'));
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, restaurant, controller),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingAndCuisine(context, restaurant),
                      const SizedBox(height: 16),
                      _buildDescription(context, restaurant),
                      const SizedBox(height: 16),
                      _buildAddress(context, restaurant),
                      const SizedBox(height: 16),
                      _buildOpeningHours(context, restaurant),
                      const SizedBox(height: 16),
                      _buildContactButtons(context, restaurant),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    Restaurant restaurant,
    RestaurantController controller,
  ) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(restaurant.name),
        background: Image.network(
          restaurant.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.restaurant,
                size: 48,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            restaurant.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: restaurant.isFavorite ? Colors.red : null,
          ),
          onPressed: () => controller.toggleFavorite(restaurant.id),
        ),
      ],
    );
  }

  Widget _buildRatingAndCuisine(BuildContext context, Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              restaurant.rating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: restaurant.cuisine.map((cuisine) {
            return Chip(
              label: Text(cuisine),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(restaurant.description),
      ],
    );
  }

  Widget _buildAddress(BuildContext context, Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(restaurant.address),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapView(
                      selectedRestaurant: restaurant,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('View on Map'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpeningHours(BuildContext context, Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opening Hours',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...restaurant.openingHours.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(entry.value.toString()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactButtons(BuildContext context, Restaurant restaurant) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _makePhoneCall(restaurant.phoneNumber),
            icon: const Icon(Icons.phone),
            label: const Text('Call'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _launchUrl(restaurant.website),
            icon: const Icon(Icons.language),
            label: const Text('Website'),
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    final restaurant = context.read<RestaurantController>().selectedRestaurant;
    if (restaurant == null) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: MapView(selectedRestaurant: restaurant),
    );
  }
}
