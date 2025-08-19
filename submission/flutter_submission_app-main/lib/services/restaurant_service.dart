import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';
import '../models/restaurant_meta.dart';

class RestaurantService {
  const RestaurantService();

  static final Map<String, Restaurant> _detailMemoryCache = <String, Restaurant>{};

  Future<RestaurantListResult> fetchRestaurantsWithMeta() async {
    // Small UX delay for shimmer consistency
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // 1) Try remote API
    try {
      final uri = Uri.parse('https://restaurant-api.dicoding.dev/list');
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final map = json.decode(res.body) as Map<String, dynamic>;
        final rawList = (map['restaurants'] as List).cast<Map<String, dynamic>>();
        final items = rawList.map<Map<String, dynamic>>((m) => {
              'id': m['id'],
              'name': m['name'],
              'city': m['city'],
              'rating': (m['rating'] as num).toDouble(),
              'description': m['description'] ?? '',
              'image': 'https://restaurant-api.dicoding.dev/images/medium/${m['pictureId']}',
            }).toList();
        final restaurants = items.map((m) => Restaurant.fromMap(m)).toList();
        // Cache to SharedPreferences for offline use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('restaurant_cache_v1', json.encode(items));
        await prefs.setInt('restaurant_cache_v1_at', DateTime.now().millisecondsSinceEpoch);
        return RestaurantListResult(items: restaurants, isOffline: false);
      }
      throw Exception('Bad status: ${res.statusCode}');
    } catch (_) {
      // 2) Fallback to cached data if available
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('restaurant_cache_v1');
        if (cached != null) {
          final list = (json.decode(cached) as List).cast<Map<String, dynamic>>();
          return RestaurantListResult(
            items: list.map((m) => Restaurant.fromMap(m)).toList(),
            isOffline: true,
          );
        }
      } catch (_) {}

      // 3) Final fallback to bundled assets
      final jsonStr = await rootBundle.loadString('assets/data/restaurants.json');
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (jsonMap['restaurants'] as List).cast<Map<String, dynamic>>();
      return RestaurantListResult(
        items: list.map((m) => Restaurant.fromMap(m)).toList(),
        isOffline: true,
      );
    }
  }

  Future<RestaurantDetailResult> fetchRestaurantDetailWithMeta(String id) async {
    // in-memory cache first
    final cached = _detailMemoryCache[id];
    if (cached != null) {
      return RestaurantDetailResult(restaurant: cached, isOffline: false);
    }
    final uri = Uri.parse('https://restaurant-api.dicoding.dev/detail/$id');
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      // try SharedPreferences fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final data = prefs.getString('detail_$id');
        if (data != null) {
          final map = json.decode(data) as Map<String, dynamic>;
          final r = Restaurant.fromMap(map);
          return RestaurantDetailResult(restaurant: r, isOffline: true);
        }
      } catch (_) {}
      throw Exception('Failed to load detail');
    }
    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    final r = jsonMap['restaurant'] as Map<String, dynamic>;
    final model = Restaurant(
      id: r['id'] as String,
      name: r['name'] as String,
      city: r['city'] as String,
      rating: (r['rating'] as num).toDouble(),
      description: r['description'] as String,
      image: 'https://restaurant-api.dicoding.dev/images/large/${r['pictureId']}',
      address: r['address'] as String,
      categories: ((r['categories'] as List?) ?? const [])
          .map((e) => (e as Map<String, dynamic>)['name'] as String)
          .toList(),
      foods: ((r['menus']?['foods'] as List?) ?? const [])
          .map((e) => (e as Map<String, dynamic>)['name'] as String)
          .toList(),
      drinks: ((r['menus']?['drinks'] as List?) ?? const [])
          .map((e) => (e as Map<String, dynamic>)['name'] as String)
          .toList(),
      reviews: ((r['customerReviews'] as List?) ?? const [])
          .map((e) => RestaurantReview.fromMap((e as Map<String, dynamic>)))
          .toList(),
    );
    _detailMemoryCache[id] = model;
    try {
      final prefs = await SharedPreferences.getInstance();
      final store = {
        'id': model.id,
        'name': model.name,
        'city': model.city,
        'rating': model.rating,
        'description': model.description,
        'image': model.image,
        'address': model.address,
        'categories': model.categories,
        'foods': model.foods,
        'drinks': model.drinks,
        'reviews': model.reviews?.map((e) => {'name': e.name, 'review': e.review, 'date': e.date}).toList(),
      };
      await prefs.setString('detail_$id', json.encode(store));
    } catch (_) {}
    return RestaurantDetailResult(restaurant: model, isOffline: false);
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    final uri = Uri.parse('https://restaurant-api.dicoding.dev/search?q=$query');
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw Exception('Failed to search');
    }
    final map = json.decode(res.body) as Map<String, dynamic>;
    final rawList = (map['restaurants'] as List).cast<Map<String, dynamic>>();
    final items = rawList.map<Map<String, dynamic>>((m) => {
          'id': m['id'],
          'name': m['name'],
          'city': m['city'],
          'rating': (m['rating'] as num).toDouble(),
          'description': m['description'] ?? '',
          'image': 'https://restaurant-api.dicoding.dev/images/small/${m['pictureId']}',
        }).toList();
    return items.map((m) => Restaurant.fromMap(m)).toList();
  }

  Future<List<RestaurantReview>> addReview({
    required String id,
    required String name,
    required String review,
  }) async {
    final uri = Uri.parse('https://restaurant-api.dicoding.dev/review');
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'id': id, 'name': name, 'review': review}),
        )
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw Exception('Failed to post review');
    }
    final map = json.decode(res.body) as Map<String, dynamic>;
    final list = (map['customerReviews'] as List).cast<Map<String, dynamic>>();
    return list.map((e) => RestaurantReview.fromMap(e)).toList();
  }
}
