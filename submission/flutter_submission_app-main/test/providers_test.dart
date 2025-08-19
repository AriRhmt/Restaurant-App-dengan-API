import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_submission_app/models/api_state.dart';
import 'package:flutter_submission_app/models/restaurant.dart';
import 'package:flutter_submission_app/providers/restaurant_providers.dart';
import 'package:flutter_submission_app/services/restaurant_service.dart';

class _FakeService extends RestaurantService {
  const _FakeService();

  @override
  Future<RestaurantDetailResult> fetchRestaurantDetailWithMeta(String id) async {
    return RestaurantDetailResult(
      restaurant: Restaurant(
        id: id,
        name: 'Fake',
        city: 'Jakarta',
        rating: 4.0,
        description: 'desc',
        image: 'http://example.com',
        address: 'Jl. Test',
        categories: const ['Asia'],
        foods: const ['Food'],
        drinks: const ['Drink'],
        reviews: const [],
      ),
      isOffline: false,
    );
  }

  @override
  Future<RestaurantListResult> fetchRestaurantsWithMeta() async {
    return RestaurantListResult(
      items: const [
        Restaurant(
          id: '1', name: 'R1', city: 'Bandung', rating: 4.3, description: 'd', image: 'http://x',
        ),
      ],
      isOffline: false,
    );
  }
}

void main() {
  test('RestaurantListProvider loads data', () async {
    final p = RestaurantListProvider(const _FakeService());
    expect(p.state, isA<ApiLoading>());
    await p.load();
    expect(p.state, isA<ApiSuccess<List<Restaurant>>>());
    final data = (p.state as ApiSuccess<List<Restaurant>>).data;
    expect(data.length, 1);
    expect(p.isOffline, false);
  });

  test('RestaurantDetailProvider loads detail', () async {
    final p = RestaurantDetailProvider(const _FakeService());
    expect(p.state, isA<ApiLoading>());
    await p.load('abc');
    expect(p.state, isA<ApiSuccess<Restaurant>>());
    final r = (p.state as ApiSuccess<Restaurant>).data;
    expect(r.id, 'abc');
    expect(r.address, 'Jl. Test');
    expect(p.isOffline, false);
  });
}

