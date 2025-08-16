import 'package:flutter/material.dart';
import 'package:orzulab/providers/cart_provider.dart'; // TO'G'RI: Fayl 'providers' papkasida
import 'package:orzulab/models/style_item.dart';
import 'package:orzulab/pages/shopping_page.dart';
import 'package:orzulab/pages/try_on_page.dart';
import 'package:orzulab/providers/style_provider.dart'; // TO'G'RI: Provider shu yerda joylashgan
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final StyleItem item;

  const DetailPage({Key? key, required this.item}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String selectedSize = 'M';
  Color selectedColor = Colors.white;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // SafeArea bilan yuqoridagi masofani to'g'irlash
          SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5, // Ekranning 50%
              child: _buildImageWithActions(context),
            ),
          ),
          // Ma'lumotlar uchun moslashuvchan pastki qism
          Expanded(
            child: _buildDetailsSection(),
          ),
        ],
      ),
    );
  }

  ///stack widget 
  Widget _buildImageWithActions(BuildContext context) {
    // Provider'ga quloq solib, joriy holatni olamiz
    // Mahsulotning eng so'nggi holatini to'g'ridan-to'g'ri ID orqali olamiz
    final currentItem =
        context.watch<StyleProvider>().getItemById(widget.item.id) ?? widget.item;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Rasm - padding bilan pastroq tushirish
        Container(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 8), // Yuqoridan ko'proq margin
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              widget.item.imageUrl,
              fit: BoxFit.cover,
              // Rasm yuklanayotganda yoki xatolik bo'lganda ko'rsatiladigan vidjet
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.error_outline,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        // Rasm ustidagi tugmalar - pastroq joylashgan
        Positioned(
          top: 30, // SafeArea dan keyin qo'shimcha margin
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.arrow_back_ios,
                onPressed: () => Navigator.pop(context),
              ),
              _buildActionButton(
                icon: currentItem.isFavorite ? Icons.favorite : Icons.favorite_border,
                iconColor: currentItem.isFavorite ? const Color.fromARGB(255, 20, 19, 19) : Colors.black,
                // Tugma bosilganda Provider'dagi funksiyani chaqiramiz
                onPressed: () => context.read<StyleProvider>().toggleFavorite(currentItem.id),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Rasm ustidagi tugmalar uchun yordamchi vidjet
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? Colors.black, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Mahsulot ma'lumotlari, tanlovlar va savatga qo'shish tugmasini o'z ichiga olgan pastki qism
  Widget _buildDetailsSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 215, 213, 213),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        border: Border(
          top: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Agar kontent sig'masa, faqat shu qism scroll bo'ladi
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24), // Padding kamaytirildi
              child: _buildDetailsContent(),
            ),
          ),
          // "Savatga qo'shish" tugmasi shu sectionning pastida
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  /// Ma'lumotlar kontentini yasaydigan vidjet
  Widget _buildDetailsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleAndCounter(),
        const SizedBox(height: 20), // Bo'shliq kamaytirildi
        _buildRating(),
        const SizedBox(height: 20), // Bo'shliq kamaytirildi
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Its simple and elegant shape makes it perfect for those of you who like you who want minimalist wedding dress. This dress is made of high-quality fabric that feels comfortable on the skin.',
          style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 20),
        _buildSizeAndColorSelectors(),
      ],
    );
  }

  /// Sarlavha va sonini o'zgartirish qismi
  Widget _buildTitleAndCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.item.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Font size kamaytirildi
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: () => setState(() => quantity > 1 ? quantity-- : null),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => setState(() => quantity++),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Reyting yulduzchalari
  Widget _buildRating() {
    return Row(
      children: [
        ...List.generate(5, (index) => Icon(
          Icons.star,
          color: index < widget.item.rating.floor() ? Colors.amber : Colors.grey[300],
          size: 18,
        )),
        const SizedBox(width: 8),
        Text(
          '${widget.item.rating} (${widget.item.reviewCount} reviews)',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  /// O'lcham va rang tanlash qismlari
  Widget _buildSizeAndColorSelectors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O'lcham tanlash
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              children: ['S', 'M', 'L', 'XL'].map((size) {
                bool isSelected = selectedSize == size;
                return GestureDetector(
                  onTap: () => setState(() => selectedSize = size),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(size, style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Rang tanlash
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              children: [
                _buildColorOption(Colors.white),
                _buildColorOption(Colors.red.shade200),
                _buildColorOption(Colors.green.shade200),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// "Try On" va "Savatga qo'shish" tugmalari
  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), // Bottom padding ko'paytirildi
      child: Row(
        children: [
          // Try On Button
          SizedBox(
            height: 50,
            width: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TryOnPage(item: widget.item)),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          // Add to Cart Button
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().addToCart(
                        widget.item,
                        quantity,
                        selectedSize,
                        selectedColor,
                      );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShoppingPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Add to Cart | \$${(widget.item.price * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rang tanlash uchun yordamchi vidjet
  Widget _buildColorOption(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}