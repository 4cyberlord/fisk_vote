/// Blog Category Model
class BlogCategory {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? color;

  BlogCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.color,
  });

  factory BlogCategory.fromJson(Map<String, dynamic> json) {
    return BlogCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug, 'icon': icon, 'color': color};
  }
}
