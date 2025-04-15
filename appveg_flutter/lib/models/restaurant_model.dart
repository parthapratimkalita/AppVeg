class Restaurant {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final List<String> cuisine;
  final double rating;
  final String imageUrl;
  bool isFavorite;
  final Map<String, dynamic> openingHours;
  final String phoneNumber;
  final String website;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.cuisine,
    required this.rating,
    required this.imageUrl,
    this.isFavorite = false,
    required this.openingHours,
    required this.phoneNumber,
    required this.website,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      description: json['description'] as String,
      cuisine: List<String>.from(json['cuisine'] as List),
      rating: json['rating'] as double,
      imageUrl: json['imageUrl'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      openingHours: json['openingHours'] as Map<String, dynamic>,
      phoneNumber: json['phoneNumber'] as String,
      website: json['website'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'cuisine': cuisine,
      'rating': rating,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'openingHours': openingHours,
      'phoneNumber': phoneNumber,
      'website': website,
    };
  }
}
