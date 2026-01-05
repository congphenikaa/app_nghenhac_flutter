class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.color,
  });

  // Factory để parse JSON từ Backend Node.js
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      // MongoDB trả về _id, ta map sang id. Nếu không có thì lấy chuỗi rỗng.
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      image: json['image'] ?? '',
      // Nếu không có color thì mặc định màu đen giống schema của bạn
      color: json['color'] ?? '#000000',
    );
  }
}
