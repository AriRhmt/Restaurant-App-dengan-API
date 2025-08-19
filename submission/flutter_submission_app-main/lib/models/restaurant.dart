class Restaurant {
  final String id;
  final String name;
  final String city;
  final double rating;
  final String description;
  final String image;

  const Restaurant({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.description,
    required this.image,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) => Restaurant(
        id: map['id'] as String,
        name: map['name'] as String,
        city: map['city'] as String,
        rating: (map['rating'] as num).toDouble(),
        description: map['description'] as String,
        image: map['image'] as String,
      );
}
