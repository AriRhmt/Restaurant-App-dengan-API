import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_submission_app/models/restaurant.dart';

void main() {
  test('Restaurant.fromMap maps detail fields correctly', () {
    final map = {
      'id': 'abc',
      'name': 'Resto',
      'city': 'Bandung',
      'rating': 4.5,
      'description': 'Desc',
      'image': 'http://example.com/img.jpg',
      'address': 'Jl. Test 1',
      'categories': ['Asia', 'Fusion'],
      'foods': ['Nasi Goreng', 'Mie Goreng'],
      'drinks': ['Teh', 'Jus'],
      'reviews': [
        {'name': 'A', 'review': 'ok', 'date': '1 Jan 2024'},
        {'name': 'B', 'review': 'nice', 'date': '2 Jan 2024'},
      ],
    };
    final r = Restaurant.fromMap(map);
    expect(r.id, 'abc');
    expect(r.name, 'Resto');
    expect(r.city, 'Bandung');
    expect(r.rating, 4.5);
    expect(r.description, 'Desc');
    expect(r.image, 'http://example.com/img.jpg');
    expect(r.address, 'Jl. Test 1');
    expect(r.categories, isNotNull);
    expect(r.categories, containsAll(<String>['Asia', 'Fusion']));
    expect(r.foods, contains('Nasi Goreng'));
    expect(r.drinks, contains('Teh'));
    expect(r.reviews, isNotNull);
    expect(r.reviews!.length, 2);
    expect(r.reviews!.first.name, 'A');
  });
}

