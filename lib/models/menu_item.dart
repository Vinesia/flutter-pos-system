class MenuItem {
  final String name;
  final String imageUrl;
  final int price;

  MenuItem({
    required this.name,
    required this.imageUrl,
    required this.price,
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
