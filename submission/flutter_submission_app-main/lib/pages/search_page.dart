import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_state.dart';
import '../models/restaurant.dart';
import '../providers/restaurant_providers.dart';
import '../widgets/custom_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Restaurants')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type to search... ',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (q) => context.read<RestaurantSearchProvider>().search(q),
            ),
          ),
          Expanded(
            child: Consumer<RestaurantSearchProvider>(
              builder: (context, provider, _) {
                final state = provider.state;
                if (state is ApiLoading<List<Restaurant>>) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ApiError<List<Restaurant>>) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.wifi_off_rounded, size: 48),
                        SizedBox(height: 8),
                        Text('Failed to search. Check connection.'),
                      ],
                    ),
                  );
                }
                final items = (state as ApiSuccess<List<Restaurant>>).data;
                if (items.isEmpty) {
                  return const Center(child: Text('No results'));
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final r = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: CustomCard(
                        onTap: () => Navigator.of(context).pushNamed('/detail', arguments: r),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 110,
                                height: 80,
                                child: CachedNetworkImage(
                                  imageUrl: r.image,
                                  fit: BoxFit.cover,
                                  placeholder: (c, _) => Container(color: Colors.black12),
                                  errorWidget: (c, _, __) => const Icon(Icons.broken_image_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.name, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 16),
                                      const SizedBox(width: 4),
                                      Flexible(child: Text(r.city, style: Theme.of(context).textTheme.bodyMedium)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                      const SizedBox(width: 4),
                                      Text(r.rating.toStringAsFixed(1)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

