class MenuItem {
  final int id;
  final String name;
  final String groupCode; // JSON'daki "groupCode" ile eşleşmeli
  final double price;
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.groupCode,
    required this.price,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as int? ?? 0, // Null gelirse 0 ata
      name: json['name'] as String? ?? "", // Null gelirse boş string
      groupCode:
          json['groupCode'] as String? ?? "", // JSON'daki tam adıyla eşleşmeli
      price:
          (json['price'] as num?)?.toDouble() ??
          0.0, // Null veya int gelirse double'a çevir
      category: json['category'] as String? ?? "",
    );
  }
}
