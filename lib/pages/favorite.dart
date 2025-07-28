import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:orzulab/pages/detail_page.dart';
import 'package:orzulab/pages/home_page.dart'; // StaggeredGridItem uchun
import 'package:orzulab/style_provider.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'dan "sevimlilar" ro'yxatini olamiz
    final favoriteItems = context.watch<StyleProvider>().favoriteItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.grey[50],
      body: favoriteItems.isEmpty
          ? _buildEmptyFavoriteState()
          : MasonryGridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return StaggeredGridItem(
                  item: item,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailPage(item: item)),
                  ),
                  // Bu yerdan ham "sevimlilar"dan olib tashlash imkoniyati
                  onFavoriteToggle: () => context.read<StyleProvider>().toggleFavorite(item.id),
                );
              },
            ),
    );
  }

  Widget _buildEmptyFavoriteState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Sevimlilar roʻyxati boʻsh',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Mahsulotlarga ♥ belgisini bosing',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
