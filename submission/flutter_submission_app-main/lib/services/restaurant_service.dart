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
}
