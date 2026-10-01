import '../../../../core/utils/json_utils.dart';

/// A category ("sphere") on the home grid.
///
/// Categories are data-driven: an admin/provider flow can add more without a
/// code change, which is why they live in Hive rather than a hard-coded list.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description = '',
    this.sortOrder = 0,
    this.isActive = true,
    this.isFeatured = false,
  });

  /// Stable slug, e.g. `arts-culture`.
  final String id;
  final String name;

  /// Photo shown inside the sphere.
  final String imageUrl;

  final String description;
  final int sortOrder;
  final bool isActive;

  /// Featured categories float to the top of the grid.
  final bool isFeatured;

  Category copyWith({
    String? name,
    String? imageUrl,
    String? description,
    int? sortOrder,
    bool? isActive,
    bool? isFeatured,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'sortOrder': sortOrder,
        'isActive': isActive,
        'isFeatured': isFeatured,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: Json.string(map['id']),
        name: Json.string(map['name']),
        imageUrl: Json.string(map['imageUrl']),
        description: Json.string(map['description']),
        sortOrder: Json.toInt(map['sortOrder']),
        isActive: Json.toBool(map['isActive'], fallback: true),
        isFeatured: Json.toBool(map['isFeatured']),
      );

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
