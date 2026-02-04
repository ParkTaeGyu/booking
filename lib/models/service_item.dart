class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.orderIndex,
    required this.active,
  });

  final String id;
  final String name;
  final int price;
  final String category;
  final int orderIndex;
  final bool active;

  static ServiceItem fromMap(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? '기타',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
    );
  }
}
