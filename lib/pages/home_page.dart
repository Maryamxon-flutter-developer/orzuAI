// pages/home_page.dart

import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:orzulab/pages/detail_page.dart';
import 'package:orzulab/providers/auth_provider.dart';
import 'package:orzulab/providers/style_provider.dart';
import 'package:orzulab/widgets/staggered_grid_item.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ❌ initState ni O'CHIRING — u muammoni keltirib chiqaradi
  // Chunki HomePage chaqirilganda userProfile hali yuklanmagan bo'lishi mumkin

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final styleProvider = context.watch<StyleProvider>();
    final items = styleProvider.displayedItems;
    final isLoading = styleProvider.isLoading;

    // 🔥 1. Agar foydalanuvchi tizimga kirmagan yoki profil hali yuklanmagan bo'lsa
    if (authProvider.status == AuthStatus.unauthenticated) {
      return const Center(child: Text("Iltimos, tizimga kiring"));
    }

    if (authProvider.status == AuthStatus.authenticating || authProvider.userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 🔥 2. Agar tizimga kirdi, lekin mahsulotlar hali yuklanmagan bo'lsa — yuklaymiz
    if (items.isEmpty && !isLoading && styleProvider.error == null) {
      context.read<StyleProvider>().loadInitialData(authProvider);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // --- Header qismi ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildGreetingSection(authProvider),
                  const SizedBox(height: 30),
                  _buildSearchBar(context),
                  const SizedBox(height: 20),
                  _buildItemsHeader(context),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            // --- Mahsulotlar ro'yxati ---
            Expanded(
              child: isLoading && items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => context
                          .read<StyleProvider>()
                          .loadInitialData(authProvider),
                      child: items.isEmpty
                          ? _buildEmptyState(styleProvider.error)
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
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(item: item),
                                    ),
                                  ),
                                  onFavoriteToggle: () => context
                                      .read<StyleProvider>()
                                      .toggleFavorite(item.id),
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

  Widget _buildGreetingSection(AuthProvider authProvider) {
    final user = authProvider.userProfile;
    final userName = user?.fullName?.split(' ').first;
    final profilePicturePath = user?.profilePicture;

    final bool hasProfilePicture =
        profilePicturePath != null && profilePicturePath.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hello, Welcome",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    userName != null ? "$userName!" : "Guest!",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 22)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          child: hasProfilePicture
              ? ClipOval(
                  child: Image(
                    image: profilePicturePath!.startsWith('http')
                        ? NetworkImage(profilePicturePath)
                        : FileImage(File(profilePicturePath)),
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      developer.log(
                        'Profil rasmini yuklab bo‘lmadi',
                        name: 'HomePage',
                        error: error,
                        stackTrace: stackTrace,
                      );
                      return const Icon(Icons.person, color: Colors.white);
                    },
                  ),
                )
              : const Icon(Icons.person, color: Colors.white),
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
        onChanged: (query) =>
            context.read<StyleProvider>().searchItems(query),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        TextButton(
          onPressed: () => context.read<StyleProvider>().searchItems(''),
          child: const Text(
            "See all",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String? error) {
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Xatolik yuz berdi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return const Center(
      child: Text(
        "Mahsulotlar topilmadi",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}