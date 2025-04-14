import 'package:flutter/material.dart';
import '../models/item.dart';
import 'item_tile.dart';

class CategorySection extends StatelessWidget {
  final String category;
  final List<Item> items;

  const CategorySection({
    super.key,
    required this.category,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: items
          .map((item) => ItemTile(item: item))
          .toList(),
    );
  }
}
