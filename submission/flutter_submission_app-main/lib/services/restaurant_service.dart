import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';

class RestaurantService {
  const RestaurantService();

  Future<List<Restaurant>> fetchRestaurants() async {
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
        return restaurants;
      }
      throw Exception('Bad status: ${res.statusCode}');
    } catch (_) {
      // 2) Fallback to cached data if available
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('restaurant_cache_v1');
        if (cached != null) {
          final list = (json.decode(cached) as List).cast<Map<String, dynamic>>();
          return list.map((m) => Restaurant.fromMap(m)).toList();
        }
      } catch (_) {}

      // 3) Final fallback to bundled assets
      final jsonStr = await rootBundle.loadString('assets/data/restaurants.json');
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (jsonMap['restaurants'] as List).cast<Map<String, dynamic>>();
      return list.map((m) => Restaurant.fromMap(m)).toList();
    }
  }

  Future<Restaurant> fetchRestaurantDetail(String id) async {
    final uri = Uri.parse('https://restaurant-api.dicoding.dev/detail/$id');
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
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
    return model;
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
