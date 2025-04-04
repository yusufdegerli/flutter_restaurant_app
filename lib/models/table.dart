class RestaurantTable {
  final int id;
  final String name;
  final int order;
  final String category;

  RestaurantTable({
    required this.id,
    required this.name,
    required this.order,
    required this.category,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      order: json['order'] ?? 0,
      category: json['category'] ?? 'General',
    );
  }
}
