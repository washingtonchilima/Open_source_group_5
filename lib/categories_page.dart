import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _categories = ['Groceries', 'Electronics', 'Clothing', 'Other'];

  void _addCategory() {
    final newCategory = _controller.text.trim();
    if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      setState(() {
        _categories.add(newCategory);
        _controller.clear();
      });
    }
  }

  void _removeCategory(int index) {
    setState(() {
      _categories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: _categories.isEmpty
                  ? const Center(child: Text('No categories yet.'))
                  : ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_categories[index]),
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
