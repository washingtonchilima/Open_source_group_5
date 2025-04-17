import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/shopping_item.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  late Box<ShoppingItem> _shoppingBox;
  late Box<String> _categoryBox;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilterCategory = 'All';

  @override
  void initState() {
    super.initState();
    _initializeHiveBoxes();
    _setupSearchListener();
  }

  Future<void> _initializeHiveBoxes() async {
    _shoppingBox = Hive.box<ShoppingItem>('shopping_items_box');
    _categoryBox = Hive.box<String>('categories_box');

    if (_categoryBox.isEmpty) {
      await _categoryBox.addAll(['Groceries', 'Electronics', 'Clothing', 'Other']);
    }
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddItemDialog() async {
    final formKey = GlobalKey<FormState>();
    String itemName = '';
    int quantity = 1;
    double price = 0.0;
    String selectedCategory = _categoryBox.getAt(0) ?? 'Uncategorized';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Shopping Item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Item Name', hintText: 'Enter item name'),
                  validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Please enter a name' : null,
                  onSaved: (value) => itemName = value?.trim() ?? '',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                        initialValue: '1',
                        validator: (value) {
                          final qty = int.tryParse(value ?? '');
                          return qty == null || qty <= 0
                              ? 'Enter valid quantity'
                              : null;
                        },
                        onSaved: (value) => quantity = int.parse(value ?? '1'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          hintText: '0.00',
                          prefixText: 'MWK ',
                        ),
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        initialValue: '0.00',
                        validator: (value) {
                          final price = double.tryParse(value ?? '');
                          return price == null || price < 0
                              ? 'Enter valid price'
                              : null;
                        },
                        onSaved: (value) => price = double.parse(value ?? '0'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: _categoryBox.values
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value != null) selectedCategory = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final item = ShoppingItem(
                  name: itemName,
                  category: selectedCategory,
                  quantity: quantity,
                  price: price,
                );
                _shoppingBox.add(item);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditItemDialog(ShoppingItem item) async {
    final formKey = GlobalKey<FormState>();
    String itemName = item.name;
    int quantity = item.quantity;
    double price = item.price;
    String selectedCategory = item.category;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Shopping Item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  initialValue: itemName,
                  validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Please enter a name' : null,
                  onSaved: (value) => itemName = value?.trim() ?? '',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                        initialValue: quantity.toString(),
                        validator: (value) {
                          final qty = int.tryParse(value ?? '');
                          return qty == null || qty <= 0
                              ? 'Enter valid quantity'
                              : null;
                        },
                        onSaved: (value) => quantity = int.parse(value ?? '1'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          prefixText: 'MWK ',
                        ),
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        initialValue: price.toStringAsFixed(2),
                        validator: (value) {
                          final price = double.tryParse(value ?? '');
                          return price == null || price < 0
                              ? 'Enter valid price'
                              : null;
                        },
                        onSaved: (value) => price = double.parse(value ?? '0'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: _categoryBox.values
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value != null) selectedCategory = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                item.name = itemName;
                item.quantity = quantity;
                item.price = price;
                item.category = selectedCategory;
                item.save();
                Navigator.pop(context);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(ShoppingItem item) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'This item will be permanently removed from your shopping list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleDelete(ShoppingItem item) async {
    await item.delete();
    if (mounted) setState(() {});
  }

  void _toggleItemChecked(ShoppingItem item) {
    item.isChecked = !item.isChecked;
    item.save();
    setState(() {});
  }

  List<ShoppingItem> _filterItems(List<ShoppingItem> items) {
    return items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery);
      final matchesCategory =
          _selectedFilterCategory == 'All' || item.category == _selectedFilterCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _shoppingBox.values.toList();
    final filteredItems = _filterItems(items);
    final totalItems = filteredItems.length;
    final checkedItems = filteredItems.where((item) => item.isChecked).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          if (checkedItems > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Chip(
                label: Text('$checkedItems/$totalItems'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedFilterCategory,
                  items: ['All', ..._categoryBox.values]
                      .map((category) =>
                      DropdownMenuItem(value: category, child: Text(category)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFilterCategory = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  leading: Checkbox(
                    value: item.isChecked,
                    onChanged: (_) => _toggleItemChecked(item),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('${item.quantity} × MWK ${item.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditItemDialog(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirmed = await _confirmDelete(item);
                          if (confirmed ?? false) _handleDelete(item);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}
