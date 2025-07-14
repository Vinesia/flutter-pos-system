class MenuItem {
  final String name;
  final String imageUrl;
  final int price;
  final String category;

  MenuItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
