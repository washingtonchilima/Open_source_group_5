class Item {
  final String name;
  final String category;
  final double price;
  final int quantity;
  bool isBought;

  Item({
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    this.isBought = false,
  });


  Item copyWith({
    String? name,
    String? category,
    double? price,
    int? quantity,
    bool? isBought,
  }) {
    return Item(
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      isBought: isBought ?? this.isBought,
    );
  }

  double get totalPrice => price * quantity;
}
