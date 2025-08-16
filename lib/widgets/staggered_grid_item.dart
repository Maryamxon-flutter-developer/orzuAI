import 'package:flutter/material.dart';
import 'package:orzulab/models/style_item.dart';

class StaggeredGridItem extends StatelessWidget {
  final StyleItem item;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const StaggeredGridItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Rasmning o'lchamini bir xil saqlash uchun
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error_outline, color: Colors.grey, size: 40),
              );
            },
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _buildFavoriteButton(),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        splashRadius: 20,
        icon: Icon(
          item.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: item.isFavorite ? Colors.redAccent : Colors.black87,
          size: 20,
        ),
        onPressed: onFavoriteToggle,
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 6),
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}