import 'package:flutter/material.dart';
import 'package:orzulab/cart_provider.dart';
import 'package:orzulab/providers/auth_provider.dart';
import 'package:orzulab/splash_page.dart'; // SplashScreen'ni import qilamiz


import 'package:orzulab/style_provider.dart';
import 'package:provider/provider.dart';

void main() {
  // SharedPreferences kabi paketlar to'g'ri ishlashi uchun kerak
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        // AuthProvider ilovaga taqdim etildi va token tekshirish boshlandi
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadToken()),
        ChangeNotifierProvider(create: (_) => StyleProvider()),
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
