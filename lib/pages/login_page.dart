import 'package:flutter/material.dart';
import 'package:orzulab/pages/bottom_bar_page.dart';

import 'package:orzulab/providers/auth_provider.dart';
import 'package:orzulab/pages/sign_up.dart';
import 'package:provider/provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Klaviaturani yopish
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.login(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        // Asinxron operatsiyadan keyin vidjet hali ham mavjudligini tekshirish
        if (!mounted) return;

        if (success) {
          // Muvaffaqiyatli bo'lsa, asosiy sahifaga o'tish va orqadagi sahifalarni yopish
          // Tokenni saqlash kerak emas, AuthProvider buni o'zi bajaradi.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const BottomNavBarpage()),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Login failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        // Xatolikni to'liq ko'rish uchun konsolga chiqarish
        print('!!! LOGIN PAGE ERROR: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // AuthProvider'ni o'qish uchun
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 218, 218),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFFD9D9D9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(height: 20),
                  Image(
                    image: AssetImage('assets/mm.png'), // Rasm yo'lini tekshiring
                    height: 100,
                    width: 140,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Email
                        buildTextField(
                          hint: 'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        // Password
                        buildTextField(
                          hint: 'Password',
                          controller: passwordController,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              disabledBackgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                            ),
                        ),

                        const SizedBox(height: 100),

                        // Sign Up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUpPage()),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[700]),
          filled: true,
          fillColor: const Color(0xFFD9D9D9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}