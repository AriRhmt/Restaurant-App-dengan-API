import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../services/favorite_service.dart';
import '../widgets/custom_card.dart';

class FavoritesPage extends StatefulWidget {
	const FavoritesPage({super.key});

	@override
	State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
	final FavoriteService _favoriteService = FavoriteService();
	List<Restaurant> _favorites = const [];
	bool _loading = true;

	@override
	void initState() {
		super.initState();
		_load();
	}

	Future<void> _load() async {
		setState(() => _loading = true);
		final rows = await _favoriteService.allFavorites();
		setState(() {
			_favorites = rows
					.map((m) => Restaurant(
						id: m['id'] as String,
						name: m['name'] as String,
						city: m['city'] as String,
						rating: (m['rating'] as num).toDouble(),
						description: m['description'] as String,
						image: m['image'] as String,
					))
					.toList();
			_loading = false;
		});
	}

	Future<void> _toggleFavorite(Restaurant r) async {
		await _favoriteService.toggleFavorite({
			'id': r.id,
			'name': r.name,
			'city': r.city,
			'rating': r.rating,
			'description': r.description,
			'image': r.image,
		});
		await _load();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Favorites')),
			body: RefreshIndicator(
				onRefresh: _load,
				child: CustomScrollView(
					physics: const BouncingScrollPhysics(),
					slivers: [
						if (_loading) ...[
							const SliverFillRemaining(
								hasScrollBody: false,
								child: Center(child: CircularProgressIndicator()),
							),
						] else if (_favorites.isEmpty) ...[
							const SliverFillRemaining(
								hasScrollBody: false,
								child: Center(
									child: Column(
										mainAxisSize: MainAxisSize.min,
										children: [
											Icon(Icons.favorite_border_rounded, size: 48),
											SizedBox(height: 8),
											Text('No favorites yet'),
										],
									),
								),
							),
						] else ...[
							SliverPadding(
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
								sliver: SliverLayoutBuilder(
									builder: (context, constraints) {
										final width = constraints.crossAxisExtent;
										int columns = 1;
										if (width >= 1200) columns = 4; else if (width >= 900) columns = 3; else if (width >= 600) columns = 2;
										return SliverGrid(
											gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
												crossAxisCount: columns,
												crossAxisSpacing: 12,
												mainAxisSpacing: 12,
												childAspectRatio: 3/2,
											),
											delegate: SliverChildBuilderDelegate(
												(context, index) {
													final r = _favorites[index];
													return _RestaurantCard(
														restaurant: r,
														isFavorite: true,
														onFavorite: () => _toggleFavorite(r),
														onTap: () => Navigator.of(context).pushNamed('/detail', arguments: r),
													);
												},
												childCount: _favorites.length,
											),
										);
									},
								),
							),
						],
					],
				),
			),
		);
	}
}

class _RestaurantCard extends StatelessWidget {
	const _RestaurantCard({
		required this.restaurant,
		required this.isFavorite,
		required this.onFavorite,
		required this.onTap,
	});

	final Restaurant restaurant;
	final bool isFavorite;
	final VoidCallback onFavorite;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return CustomCard(
			onTap: onTap,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Hero(
						tag: 'rest_${restaurant.id}',
						child: ClipRRect(
							borderRadius: BorderRadius.circular(12),
							child: AspectRatio(
								aspectRatio: 16 / 9,
								child: CachedNetworkImage(imageUrl: restaurant.image, fit: BoxFit.cover, placeholder: (c,_)=>Container(color: Colors.black12), errorWidget: (c,_,__)=>(const Icon(Icons.broken_image_rounded))),
							),
						),
					),
					const SizedBox(height: 10),
					Row(
						children: [
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(restaurant.name, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
										const SizedBox(height: 4),
										Row(
											children: [
												const Icon(Icons.location_on_rounded, size: 16),
												const SizedBox(width: 4),
												Flexible(child: Text(restaurant.city, style: Theme.of(context).textTheme.bodyMedium)),
											],
										),
									],
								),
							),
							IconButton(
								icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Colors.pinkAccent),
								onPressed: onFavorite,
							)
						],
					),
					const SizedBox(height: 6),
					Row(
						children: [
							const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
							const SizedBox(width: 4),
							Text(restaurant.rating.toStringAsFixed(1)),
						]
					)
				],
			),
		);
	}
}


