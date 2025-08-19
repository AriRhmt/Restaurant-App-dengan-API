import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/api_state.dart';
import '../models/restaurant.dart';
import '../services/favorite_service.dart';
import '../providers/restaurant_providers.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _favoriteService = FavoriteService();
  bool _isFav = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final r = ModalRoute.of(context)!.settings.arguments as Restaurant?;
    if (r != null) {
      context.read<RestaurantDetailProvider>().load(r.id);
      _favoriteService.isFavorite(r.id).then((v) => setState(() => _isFav = v));
    }
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Restaurant?;
    if (arg == null) {
      return const Scaffold(
          body: SafeArea(child: Center(child: Text('Not found'))));
    }
    return Scaffold(
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          if (state is ApiLoading<Restaurant>) {
            // Shimmer skeleton while loading detail
            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(height: 24, width: 240, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(height: 18, width: 160, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(height: 18, width: 100, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Column(
                        children: [
                          Container(height: 14, width: double.infinity, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 14, width: double.infinity, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 14, width: 200, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (c, i) => Container(width: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                          separatorBuilder: (c, i) => const SizedBox(width: 8),
                          itemCount: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (c, i) => Container(width: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                          separatorBuilder: (c, i) => const SizedBox(width: 8),
                          itemCount: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is ApiError<Restaurant>) {
            final err = state.error;
            String message = 'Failed to load restaurant detail';
            if (err is TimeoutException) message = 'Timeout saat memuat detail';
            if (err is SocketException) message = 'Tidak ada koneksi internet';
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<RestaurantDetailProvider>().load(arg.id),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final providerOffline = context.read<RestaurantDetailProvider>().isOffline;
          final restaurant = (state as ApiSuccess<Restaurant>).data;
          return RefreshIndicator(
            onRefresh: () async => context.read<RestaurantDetailProvider>().load(arg.id),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (providerOffline)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orangeAccent),
                    ),
                    child: const Text('Offline data: menampilkan data tersimpan.'),
                  ),
                Stack(
                  children: [
                    Hero(
                      tag: 'rest_${restaurant.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                              imageUrl: restaurant.image,
                              fit: BoxFit.cover,
                              placeholder: (c, _) => Container(color: Colors.black12),
                              errorWidget: (c, _, __) => (const Icon(Icons.broken_image_rounded))),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Material(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(28),
                        child: IconButton(
                          tooltip: 'Favorite',
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              key: ValueKey(_isFav),
                              color: Colors.pinkAccent,
                            ),
                          ),
                          onPressed: () async {
                            await _favoriteService.toggleFavorite({
                              'id': restaurant.id,
                              'name': restaurant.name,
                              'city': restaurant.city,
                              'rating': restaurant.rating,
                              'description': restaurant.description,
                              'image': restaurant.image,
                            });
                            final v = await _favoriteService.isFavorite(restaurant.id);
                            if (mounted) setState(() => _isFav = v);
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Back',
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Hero(
                  tag: 'title_${restaurant.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(restaurant.name, style: Theme.of(context).textTheme.headlineMedium),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 18),
                    const SizedBox(width: 6),
                    Flexible(child: Text('${restaurant.city}${restaurant.address != null ? ' • ${restaurant.address}' : ''}')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(restaurant.rating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 16),
                if ((restaurant.categories ?? []).isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: restaurant.categories!
                        .map((c) => Chip(label: Text(c)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  restaurant.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                if ((restaurant.foods ?? []).isNotEmpty) ...[
                  Text('Foods', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (c, i) => _ChipCard(text: restaurant.foods![i]),
                      separatorBuilder: (c, i) => const SizedBox(width: 8),
                      itemCount: restaurant.foods!.length,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if ((restaurant.drinks ?? []).isNotEmpty) ...[
                  Text('Drinks', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (c, i) => _ChipCard(text: restaurant.drinks![i]),
                      separatorBuilder: (c, i) => const SizedBox(width: 8),
                      itemCount: restaurant.drinks!.length,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if ((restaurant.reviews ?? []).isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: const Text('Belum ada ulasan.'),
                  )
                else
                  ...(restaurant.reviews ?? const <RestaurantReview>[])
                      .map((rev) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).dividerColor)),
                              title: Text(rev.name),
                              subtitle: Text(rev.review),
                              trailing: Text(rev.date, style: Theme.of(context).textTheme.bodySmall),
                            ),
                          )),
                const SizedBox(height: 8),
                _ReviewForm(onSubmit: (name, review) async {
                  await context.read<RestaurantDetailProvider>().addReview(name, review);
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChipCard extends StatelessWidget {
  const _ChipCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ReviewForm extends StatefulWidget {
  const _ReviewForm({required this.onSubmit});
  final Future<void> Function(String name, String review) onSubmit;

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _key = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _revCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _revCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Your name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _revCtrl,
            decoration: const InputDecoration(labelText: 'Your review'),
            minLines: 2,
            maxLines: 4,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _submitting
                  ? null
                  : () async {
                      if (!_key.currentState!.validate()) return;
                      setState(() => _submitting = true);
                      try {
                        await widget.onSubmit(_nameCtrl.text.trim(), _revCtrl.text.trim());
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted')));
                        _revCtrl.clear();
                      } catch (_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit review')));
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
              child: Text(_submitting ? 'Submitting...' : 'Submit Review'),
            ),
          )
        ],
      ),
    );
  }
}
