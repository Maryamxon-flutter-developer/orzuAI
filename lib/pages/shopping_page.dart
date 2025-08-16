import 'package:flutter/material.dart';
import 'package:orzulab/providers/cart_provider.dart';
import 'package:orzulab/pages/pay.dart';

import 'package:provider/provider.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  bool selectAll = false;
  Set<int> selectedItems = {}; // Tanlangan mahsulotlar
  Set<String> favoriteItems = {}; // Sevimli mahsulotlar

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    double subtotal = cart.items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
    double discount = 50.0;
    double total = subtotal - discount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Opacity(
          opacity: cart.items.isEmpty ? 0.0 : 1.0,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            // Agar tugma ko'rinmas bo'lsa, uni bosib bo'lmaydigan qilamiz
            onPressed: cart.items.isEmpty ? null : () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          '',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Savatda hozircha mahsulot yo\'q',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Select All Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Text(
                        'Select all',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectAll = !selectAll;
                            if (selectAll) {
                              selectedItems = {
                                for (int i = 0; i < cart.items.length; i++) i
                              };
                            } else {
                              selectedItems.clear();
                            }
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: selectAll ? Colors.green : Colors.transparent,
                            border: Border.all(
                              color: selectAll ? Colors.green : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: selectAll
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Cart Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final product = cart.items[i].product;
                      final cartItem = cart.items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Checkbox
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedItems.contains(i)) {
                                    selectedItems.remove(i);
                                  } else {
                                    selectedItems.add(i);
                                  }
                                  selectAll = selectedItems.length == cart.items.length;
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: selectedItems.contains(i) ? Colors.green : Colors.transparent,
                                  border: Border.all(
                                    color: selectedItems.contains(i) ? Colors.green : Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: selectedItems.contains(i)
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                product.imageUrl,
                                width: 80,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Romantic style',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Color: ${cart.items[i].size}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Market: ${product.title}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Quantity Controls
                                  Row(
                                    children: [
                                      Material(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () {
                                            cart.decreaseQuantity(cartItem);
                                          },
                                          child: const SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: Icon(
                                              Icons.remove,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '${cartItem.quantity}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Material(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () {
                                            cart.increaseQuantity(cartItem);
                                          },
                                          child: const SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: Icon(
                                              Icons.add,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Heart Icon (Favorites)
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // Agar mahsulot sevimlilarda bo'lsa, olib tashlaymiz
                                      if (favoriteItems.contains(product.title)) {
                                        favoriteItems.remove(product.title);
                                      } else {
                                        // Aks holda, sevimlilarga qo'shamiz
                                        favoriteItems.add(product.title);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: favoriteItems.contains(product.title)
                                          ? Colors.red.shade50
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      favoriteItems.contains(product.title)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: favoriteItems.contains(product.title)
                                          ? Colors.red.shade400
                                          : Colors.grey.shade500,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Order Summary Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${cart.items.length} orders',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '\$${subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Discount',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '\$${discount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Payment Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // To'lov sahifasiga o'tish
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(), // PaymentPage() bu sizning to'lov sahifangiz
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Go to payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
