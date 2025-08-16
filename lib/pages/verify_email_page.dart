import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orzulab/pages/bottom_bar_page.dart';
import 'package:orzulab/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get verificationCode {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyEmail() async {
    FocusScope.of(context).unfocus();
    
    if (verificationCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyEmail(verificationCode);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBarpage()),
        (route) => false,
      );
    } else if (mounted) {
      final errorMessage = authProvider.error ?? 'Verification failed.';
      print('[VERIFY_EMAIL_PAGE_ERROR]: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendVerificationCode();
    if (mounted) {
      final message = success ? 'A new code has been sent.' : authProvider.error ?? 'Failed to resend code.';
      if (!success) {
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

  Widget _buildCodeInput(int index) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
        onTap: () {
          _controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index].text.length),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Provider.of<AuthProvider>(context, listen: false).cancelRegistration();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Logo section
            Container(
              margin: const EdgeInsets.only(top: 40, bottom: 60),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ORZU LAB AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'Artificial intelligence system design',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Title
            const Text(
              'Verify',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Please enter the code we just sent to email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Email display
            Text(
              authProvider.pendingEmail ?? 'your email',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),

            // Code input fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildCodeInput(index)),
            ),
            const SizedBox(height: 40),

            // Resend option
            Column(
              children: [
                const Text(
                  "Didn't receive the code?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: authProvider.isLoading ? null : _resendCode,
                  child: const Text(
                    'Resend code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Verify button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(bottom: 40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: authProvider.isLoading ? null : _verifyEmail,
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}