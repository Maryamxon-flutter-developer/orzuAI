// models/style_item.dart

class StyleItem {
  final String id;
  final String title;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final String category;
  final double price;
  final double imageHeight;

  StyleItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isFavorite,
    required this.category,
    required this.price,
    required this.imageHeight,
  });

  factory StyleItem.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final firstImage = (json['images'] as List).first;
      if (firstImage is Map<String, dynamic>) {
        imageUrl = firstImage['image'] ?? firstImage['url'] ?? '';
      }
    }

    return StyleItem(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? 'Nomsiz mahsulot',
      imageUrl: imageUrl,
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      reviewCount: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      isFavorite: json['is_favorite'] ?? false,
      category: json['category'] ?? 'Kategoriyasiz',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      imageHeight: double.tryParse(json['image_height']?.toString() ?? '180.0') ?? 180.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'image': imageUrl,
      'rating': rating,
      'likes': reviewCount,
      'is_favorite': isFavorite,
      'category': category,
      'price': price,
      'image_height': imageHeight,
    };
  }

  StyleItem copyWith({bool? isFavorite}) {
    return StyleItem(
      id: id,
      title: title,
      imageUrl: imageUrl,
      rating: rating,
      reviewCount: reviewCount,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category,
      price: price,
      imageHeight: imageHeight,
    );
  }
}