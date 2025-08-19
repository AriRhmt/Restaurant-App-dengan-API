import '../models/item.dart';

class DataService {
  const DataService();

  List<Item> fetchItems() => const [
        Item(
          id: '1',
          title: 'Healthy Meal',
          subtitle: 'Grilled salmon with veggies',
          imageUrl:
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=640',
        ),
        Item(
          id: '2',
          title: 'Morning Run',
          subtitle: '5km in the park',
          imageUrl:
              'https://images.unsplash.com/photo-1517963628607-235ccdd5476f?w=640',
        ),
        Item(
          id: '3',
          title: 'Hydration',
          subtitle: '8 cups goal',
          imageUrl:
              'https://images.unsplash.com/photo-1532634726-8b9fb99825c7?w=640',
        ),
        Item(
          id: '4',
          title: 'Sleep',
          subtitle: '7h 30m last night',
          imageUrl:
              'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=640',
        ),
      ];
}
