import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.item, this.onTap});
  final Item item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: Hero(
        tag: 'img_${item.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(item.imageUrl,
              width: 56, height: 56, fit: BoxFit.cover),
        ),
      ),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle:
          Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
