import 'package:flutter/material.dart';
import 'package:orzulab/pages/bottom_bar_page.dart';
import 'package:orzulab/pages/login_page.dart';
import 'package:orzulab/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    switch (authProvider.status) {
      case AuthStatus.unknown:
        // "Nazoratchi" hujjatni tekshirmoqda
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case AuthStatus.unauthenticated:
      case AuthStatus.authenticating:
        // Hujjat yo'q, "hujjat to'g'rilash bo'limi"ga (Login) yuborish
        return const LoginPage();

      case AuthStatus.authenticated:
        // Hujjat bor, asosiy binoga (Asosiy sahifa) kirish
        return const BottomNavBarpage();
    }
  }
}