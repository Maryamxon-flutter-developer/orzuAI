import 'package:flutter/material.dart';
import 'package:orzulab/bottom_bar_page.dart';
import 'package:orzulab/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final TextEditingController codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _verifyEmail() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.verifyEmail(codeController.text.trim());

      if (success && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBarpage()),
          (route) => false,
        );
      } else if (mounted) {
        final errorMessage = authProvider.error ?? 'Verification failed.';
        // Xatolikni debug console'ga chiqarish
        print('[VERIFY_EMAIL_PAGE_ERROR]: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resendCode() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendVerificationCode();
    if (mounted) {
      final message = success ? 'A new code has been sent.' : authProvider.error ?? 'Failed to resend code.';
      if (!success) {
        // Xatolikni debug console'ga chiqarish
        print('[RESEND_CODE_ERROR]: $message');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Register jarayonini bekor qilish
            Provider.of<AuthProvider>(context, listen: false).cancelRegistration();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'A verification code has been sent to:',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                authProvider.pendingEmail ?? 'your email',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 10),
                decoration: const InputDecoration(
                  hintText: '______',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length != 6) {
                    return 'Please enter the 6-digit code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: authProvider.isLoading ? null : _verifyEmail,
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: authProvider.isLoading ? null : _resendCode,
                child: const Text('Resend Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}