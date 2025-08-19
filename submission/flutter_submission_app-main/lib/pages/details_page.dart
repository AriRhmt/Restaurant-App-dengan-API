import 'package:flutter/material.dart';
import '../models/item.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as Item?;
    if (item == null) {
      return const Scaffold(body: Center(child: Text('No item')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'img_${item.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(item.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(item.subtitle, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
