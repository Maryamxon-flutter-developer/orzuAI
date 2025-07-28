import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:orzulab/pages/detail_page.dart';
import 'package:orzulab/style_provider.dart';
import 'package:provider/provider.dart';

// Model classes
class User {
  final String name;
  final String profileImage;
  final String greeting;

  User({required this.name, required this.profileImage, required this.greeting});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      profileImage: json['profile_image'],
      greeting: json['greeting'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profile_image': profileImage,
      'greeting': greeting,
    };
  }
}

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
    return StyleItem(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      rating: json['rating'].toDouble(),
      reviewCount: json['review_count'],
      isFavorite: json['is_favorite'],
      category: json['category'],
      price: json['price'].toDouble(),
      imageHeight: json['image_height']?.toDouble() ?? 180.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'is_favorite': isFavorite,
      'category': category,
      'price': price,
      'image_height': imageHeight,
    };
  }

  StyleItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    bool? isFavorite,
    String? category,
    double? price,
    double? imageHeight,
  }) {
    return StyleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      price: price ?? this.price,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }
}

// Data Service
class DataService {
  static final Random _random = Random();
  
  static Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return User(
      name: 'Lily Collins',
      profileImage: 'assets/nn.jpg',
      greeting: 'Hello, Welcome 👋',
    );
  }

  static Future<List<StyleItem>> getAllStyles() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return [
      StyleItem(
        id: '1',
        title: 'Minimalistic style',
        imageUrl: 'assets/pp.png',
        rating: 4.5,
        reviewCount: 128,
        isFavorite: false,
        category: 'minimalistic',
        price: 299.99,
        imageHeight: 180.0,
      ),
      StyleItem(
        id: '2',
        title: 'Romantic style',
        imageUrl: 'assets/i.png',
        rating: 4.8,
        reviewCount: 95,
        isFavorite: true,
        category: 'romantic',
        price: 399.99,
        imageHeight: 220.0,
      ),
      StyleItem(
        id: '3',
        title: 'Classic style',
        imageUrl: 'assets/q.png',
        rating: 4.3,
        reviewCount: 67,
        isFavorite: false,
        category: 'classic',
        price: 349.99,
        imageHeight: 160.0,
      ),
      StyleItem(
        id: '4',
        title: 'Modern style',
        imageUrl: 'assets/pp.png',
        rating: 4.7,
        reviewCount: 156,
        isFavorite: false,
        category: 'modern',
        price: 459.99,
        imageHeight: 200.0,
      ),
      StyleItem(
        id: '5',
        title: 'Vintage Collection',
        imageUrl: 'assets/vintage.png',
        rating: 4.2,
        reviewCount: 87,
        isFavorite: true,
        category: 'vintage',
        price: 275.99,
        imageHeight: 240.0,
      ),
      StyleItem(
        id: '6',
        title: 'Casual Wear',
        imageUrl: 'assets/casual.png',
        rating: 4.6,
        reviewCount: 203,
        isFavorite: false,
        category: 'casual',
        price: 189.99,
        imageHeight: 170.0,
      ),
      StyleItem(
        id: '7',
        title: 'Formal Elegance',
        imageUrl: 'assets/formal.png',
        rating: 4.9,
        reviewCount: 134,
        isFavorite: true,
        category: 'formal',
        price: 599.99,
        imageHeight: 210.0,
      ),
      StyleItem(
        id: '8',
        title: 'Bohemian Style',
        imageUrl: 'assets/boho.png',
        rating: 4.4,
        reviewCount: 76,
        isFavorite: false,
        category: 'bohemian',
        price: 329.99,
        imageHeight: 190.0,
      ),
    ];
  }

  static Future<bool> updateFavoriteStatus(String itemId, bool isFavorite) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  static Future<List<StyleItem>> searchStyles(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final allStyles = await getAllStyles();
    return allStyles.where((item) => 
      item.title.toLowerCase().contains(query.toLowerCase()) ||
      item.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static Future<List<StyleItem>> getStylesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final allStyles = await getAllStyles();
    return allStyles.where((item) => item.category == category).toList();
  }
}

// Custom Staggered Grid Widget
class StaggeredGridItem extends StatelessWidget {
  final StyleItem item;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const StaggeredGridItem({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container with dynamic height
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: item.imageHeight,
                    child: item.imageUrl.isNotEmpty
                        ? Image.asset(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        item.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: item.isFavorite
                            ? const Color.fromARGB(255, 16, 16, 16)
                            : Colors.grey[600],
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < item.rating.floor()
                              ? Icons.star
                              : (index < item.rating ? Icons.star_half : Icons.star_border),
                          size: 12,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '(${item.reviewCount})',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      width: double.infinity,
      height: double.infinity,
      // Placeholder sifatida assets papkasidagi rasmdan foydalanamiz
      child: Image.asset(
        'assets/i.png', // Mavjud rasmlardan birini qo'yishingiz mumkin
        fit: BoxFit.cover,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'dan ma'lumotlarni olish
    final styleProvider = context.watch<StyleProvider>();
    final user = styleProvider.user;
    final items = styleProvider.allItems;
    final isLoading = styleProvider.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Greeting section
                  _buildGreetingSection(user),
                  
                  const SizedBox(height: 30),
                  
                  // Search bar
                  _buildSearchBar(context),
                  
                  const SizedBox(height: 20),
                  
                  // All Items header
                  _buildItemsHeader(context),
                  
                  const SizedBox(height: 10),
                ],
              ),
            ),
            
            // Grid content
            Expanded(
              child: isLoading && items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => context.read<StyleProvider>().loadInitialData(),
                      child: items.isEmpty
                          ? _buildEmptyState()
                          : MasonryGridView.count(
                              padding: const EdgeInsets.all(16),
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return StaggeredGridItem(
                                  item: item,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DetailPage(item: item)),
                                  ),
                                  onFavoriteToggle: () => context.read<StyleProvider>().toggleFavorite(item.id),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection(User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.greeting ?? "Hello, Welcome 👋",
                style: const TextStyle(
                  fontSize: 16, 
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.name ?? "Loading...",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.grey,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        onChanged: (query) => context.read<StyleProvider>().searchItems(query),
        decoration: InputDecoration(
          hintText: "Search styles...",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildItemsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "All Items",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        TextButton(
          onPressed: () {
            // Qidiruvni tozalab, barcha elementlarni ko'rsatish
            context.read<StyleProvider>().searchItems('');
          },
          child: const Text("See all", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "Mahsulotlar topilmadi",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}