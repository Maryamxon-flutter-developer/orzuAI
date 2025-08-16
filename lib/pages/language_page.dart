import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        children: [
          _buildLanguageOption('English'),
          _buildLanguageOption('Русский'),
          _buildLanguageOption('O‘zbekcha'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String title) {
    return RadioListTile<String>(
      title: Text(title),
      value: title,
      groupValue: _selectedLanguage,
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _selectedLanguage = value;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$value selected')),
          );
        }
      },
      activeColor: Colors.black,
    );
  }
}