class Restaurant {
  final String id;
  final String name;
  final String city;
  final double rating;
  final String description;
  final String image;

  // Detail fields
  final String? address;
  final List<String>? foods;
  final List<String>? drinks;
  final List<RestaurantReview>? reviews;

  const Restaurant({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.description,
    required this.image,
    this.address,
    this.foods,
    this.drinks,
    this.reviews,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) => Restaurant(
        id: map['id'] as String,
        name: map['name'] as String,
        city: map['city'] as String,
        rating: (map['rating'] as num).toDouble(),
        description: map['description'] as String,
        image: map['image'] as String,
        address: map['address'] as String?,
        foods: (map['foods'] as List?)?.map((e) => e as String).toList(),
        drinks: (map['drinks'] as List?)?.map((e) => e as String).toList(),
        reviews: (map['reviews'] as List?)
            ?.map((e) => RestaurantReview.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}

class RestaurantReview {
  final String name;
  final String review;
  final String date;

  const RestaurantReview({
    required this.name,
    required this.review,
    required this.date,
  });

  factory RestaurantReview.fromMap(Map<String, dynamic> map) => RestaurantReview(
        name: map['name'] as String,
        review: map['review'] as String,
        date: map['date'] as String,
      );
}
