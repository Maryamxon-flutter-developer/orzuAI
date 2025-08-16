import 'package:flutter/material.dart';
import 'package:orzulab/models/user_profile.dart';
import 'package:orzulab/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile currentUser;

  const EditProfilePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.fullName);
    _phoneController = TextEditingController(text: widget.currentUser.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // If the form data is valid
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        // Update profile information via Provider
        await authProvider.updateProfile(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
          Navigator.pop(context); // Go back
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An error occurred: $e")),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
                )
              : IconButton(
                  icon: const Icon(Icons.save_outlined),
                  onPressed: _saveProfile,
                  tooltip: "Save",
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true) ? "Please enter your name." : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? "Please enter your phone number."
                    : null,
              ),
            ],
          )
        ),
      ),
    );
  }
}