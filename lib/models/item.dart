class Item {
  String name;
  String category;
  int quantity;
  double price;
  bool isBought;

  Item({
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    this.isBought = false,
  });

  double get totalPrice => quantity * price;
}
