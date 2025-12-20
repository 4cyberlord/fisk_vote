/// Blog Author Model
class BlogAuthor {
  final int id;
  final String name;
  final String? avatar;

  BlogAuthor({required this.id, required this.name, this.avatar});

  factory BlogAuthor.fromJson(Map<String, dynamic> json) {
    return BlogAuthor(
      id: json['id'] as int,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar};
  }
}
