import 'package:flutter/material.dart';
import 'package:orzulab/providers/cart_provider.dart';
import 'package:orzulab/providers/auth_provider.dart';
import 'package:orzulab/providers/style_provider.dart';
import 'package:orzulab/services/product_service.dart';
import 'package:orzulab/pages/splash_page.dart';

import 'package:provider/provider.dart';

void main() {
  // SharedPreferences kabi paketlar to'g'ri ishlashi uchun kerak
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        // 1. ProductService'ni butun ilova uchun bitta nusxada taqdim etamiz.
        Provider<ProductService>(
          create: (_) => ProductService(),
        ),
        // AuthProvider ilovaga taqdim etildi va token tekshirish boshlandi
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => StyleProvider(context.read<ProductService>()),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // Ilova endi SplashScreen'dan boshlanadi
      home: const SplashScreen(),
    );
  }
}
