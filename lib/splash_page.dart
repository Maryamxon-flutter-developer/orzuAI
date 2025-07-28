import 'dart:async';
import 'package:flutter/material.dart';
import 'package:orzulab/login_page.dart';
import 'package:orzulab/onboarding_page.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 soniyadan keyin SignUpScreen'ga o'tish uchun taymer
    Timer(
      const Duration(seconds: 5),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrzuLabApp()),
      ),
    );
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
