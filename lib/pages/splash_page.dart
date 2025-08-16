import 'dart:async';
import 'package:flutter/material.dart';
import 'package:orzulab/pages/bottom_bar_page.dart'; // Tizimga kirgandan keyingi asosiy sahifa
import 'package:orzulab/pages/login_page.dart';
import 'package:orzulab/pages/onboarding_page.dart'; // Bu faylda OrzuLabHomePage joylashgan
import 'package:orzulab/services/auth_service.dart'; // Tokenni tekshirish uchun
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    // Splash screen ko'rinib turishi uchun kichik kechikish
    await Future.delayed(const Duration(seconds: 3));

    // Kerakli ma'lumotlarni olamiz
    final prefs = await SharedPreferences.getInstance();
    // "onboardingKorildi" belgisini xotiradan o'qiymiz. Agar yo'q bo'lsa, `false` deb olamiz.
    final bool onboardingKorildi = prefs.getBool('onboardingKorildi') ?? false;

    // Asinxron operatsiyadan keyin widget hali ham mavjudligini tekshirish
    if (!mounted) return;

    // Mantiq asosida kerakli sahifaga yo'naltiramiz
    if (!onboardingKorildi) {
      // Agar onboarding hali ko'rilmagan bo'lsa, OnboardingPage'ga o'tamiz
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    } else {
      // Agar onboarding ko'rilgan bo'lsa, foydalanuvchi har doim Login sahifasiga o'tadi.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/PP.png',
            fit: BoxFit.cover,
          ),
          // Dizaynni saqlab qolish uchun eski kod
          const Center(
            child: Text(
              'OrzulabAI',
              style: TextStyle(
                fontFamily: 'Rochester',
                fontSize: 48,
                color: Color.fromARGB(255, 247, 247, 248), 
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB (150, 0, 0, 0),
                  ),
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 8.0,
                    color: Color.fromARGB(125, 0, 0, 0 ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
