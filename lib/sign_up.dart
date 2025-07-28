import 'package:flutter/material.dart';
import 'package:orzulab/login_page.dart';
import 'package:orzulab/providers/auth_provider.dart';
import 'package:orzulab/verify_email_page.dart'; // Yangi sahifa
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    password2Controller.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        fullNameController.text.trim(),
        emailController.text.trim(),
        phoneController.text.trim(),
        passwordController.text.trim(),
        password2Controller.text.trim(),
      );

      if (success && mounted) {
        // Muvaffaqiyatli bo'lsa, tasdiqlash sahifasiga o'tish
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyEmailPage()),
        );
      } else if (mounted) {
        // Xatolikni ko'rsatish
        final errorMessage = authProvider.error ?? 'Sign up failed. Please try again.';
        // Xatolikni debug console'ga chiqarish
        print('[SIGN_UP_PAGE_ERROR]: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 222, 221, 221),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 221, 219, 219),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(26),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Full Name
                        buildInputField(
                          hint: 'Full Name',
                          controller: fullNameController,
                          validator: (val) => val!.isEmpty ? 'Enter your full name' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Email
                        buildInputField(
                          hint: 'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => (val!.isEmpty || !val.contains('@')) ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Phone Number
                        buildInputField(
                          hint: 'Phone number',
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (val) => val!.isEmpty ? 'Enter your phone number' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Password
                        buildInputField(
                          hint: 'Password',
                          controller: passwordController,
                          isPassword: true,
                          validator: (val) => val!.length < 6 ? 'Password must be at least 6 characters' : null,
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        buildInputField(
                          hint: 'Confirm Password',
                          controller: password2Controller,
                          isPassword: true,
                          validator: (val) {
                            if (val != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        
                        // Sign Up Button
                        GestureDetector(
                          onTap: authProvider.isLoading ? null : _signUp,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: authProvider.isLoading ? Colors.grey : Colors.black,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: authProvider.isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text(
                                      'Sign Up',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                        
                        // Sign In link
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            "Already have an account? Sign In",
                            style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w400),
                          ),
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

  Widget buildInputField({
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: const Color(0xFFD9D9D9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
