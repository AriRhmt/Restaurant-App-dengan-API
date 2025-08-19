import 'restaurant.dart';

class RestaurantListResult {
  final List<Restaurant> items;
  final bool isOffline;

  const RestaurantListResult({required this.items, required this.isOffline});
}

class RestaurantDetailResult {
  final Restaurant restaurant;
  final bool isOffline;

  const RestaurantDetailResult({required this.restaurant, required this.isOffline});
}

