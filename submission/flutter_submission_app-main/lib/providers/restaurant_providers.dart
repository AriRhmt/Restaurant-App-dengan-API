import 'package:flutter/foundation.dart';
import '../models/api_state.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';

class RestaurantListProvider extends ChangeNotifier {
  final RestaurantService _service;
  ApiState<List<Restaurant>> state = const ApiLoading();

  RestaurantListProvider(this._service);

  Future<void> load() async {
    state = const ApiLoading();
    notifyListeners();
    try {
      final data = await _service.fetchRestaurants();
      state = ApiSuccess<List<Restaurant>>(data);
    } catch (e, st) {
      state = ApiError<List<Restaurant>>(e, st);
    }
    notifyListeners();
  }
}

class RestaurantDetailProvider extends ChangeNotifier {
  final RestaurantService _service;
  ApiState<Restaurant> state = const ApiLoading();

  RestaurantDetailProvider(this._service);

  Future<void> load(String id) async {
    state = const ApiLoading();
    notifyListeners();
    try {
      final data = await _service.fetchRestaurantDetail(id);
      state = ApiSuccess<Restaurant>(data);
    } catch (e, st) {
      state = ApiError<Restaurant>(e, st);
    }
    notifyListeners();
  }

  Future<void> addReview(String name, String review) async {
    if (state is! ApiSuccess<Restaurant>) return;
    final current = (state as ApiSuccess<Restaurant>).data;
    try {
      final reviews = await _service.addReview(id: current.id, name: name, review: review);
      state = ApiSuccess<Restaurant>(Restaurant(
        id: current.id,
        name: current.name,
        city: current.city,
        rating: current.rating,
        description: current.description,
        image: current.image,
        address: current.address,
        foods: current.foods,
        drinks: current.drinks,
        reviews: reviews,
      ));
      notifyListeners();
    } catch (_) {}
  }
}

class RestaurantSearchProvider extends ChangeNotifier {
  final RestaurantService _service;
  ApiState<List<Restaurant>> state = const ApiSuccess<List<Restaurant>>([]);

  RestaurantSearchProvider(this._service);

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const ApiSuccess<List<Restaurant>>([]);
      notifyListeners();
      return;
    }
    state = const ApiLoading();
    notifyListeners();
    try {
      final data = await _service.searchRestaurants(query);
      state = ApiSuccess<List<Restaurant>>(data);
    } catch (e, st) {
      state = ApiError<List<Restaurant>>(e, st);
    }
    notifyListeners();
  }
}

