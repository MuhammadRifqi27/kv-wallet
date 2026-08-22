enum CategoryType { income, expense }

extension CategoryTypeLabel on CategoryType {
  String get label => switch (this) {
        CategoryType.income => 'Pemasukan',
        CategoryType.expense => 'Pengeluaran',
      };
}

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: CategoryType.values.byName(json['type'] as String),
      description: json['description'] as String?,
    );
  }

  final int id;
  final String name;
  final CategoryType type;
  final String? description;
}
