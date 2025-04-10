import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _controller = TextEditingController();
  late Box<String> _categoryBox;

  @override
  void initState() {
    super.initState();
    _categoryBox = Hive.box<String>('categories_box');

    // Add default categories if it's the first time
    if (_categoryBox.isEmpty) {
      _categoryBox.addAll(['Groceries', 'Electronics', 'Clothing', 'Others']);
    }
  }

  void _addCategory() {
    final newCategory = _controller.text.trim();
    if (newCategory.isNotEmpty && !_categoryBox.values.contains(newCategory)) {
      _categoryBox.add(newCategory);
      _controller.clear();
      setState(() {});
    }
  }

  void _removeCategory(int index) {
    _categoryBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoryBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'New Category',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ),
              onSubmitted: (_) => _addCategory(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: categories.isEmpty
                  ? const Center(child: Text('No categories yet.'))
                  : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(categories[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeCategory(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
