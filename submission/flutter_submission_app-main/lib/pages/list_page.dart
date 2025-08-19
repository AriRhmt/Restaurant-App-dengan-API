import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/data_service.dart';
import '../widgets/item_tile.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final _service = const DataService();
  late final List<Item> _allItems;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _allItems = _service.fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allItems
        .where((e) =>
            e.title.toLowerCase().contains(_query.toLowerCase()) ||
            e.subtitle.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Logs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return ItemTile(
                  item: item,
                  onTap: () => Navigator.of(context)
                      .pushNamed('/details', arguments: item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
