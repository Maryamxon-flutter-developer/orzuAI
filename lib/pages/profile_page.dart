import 'package:flutter/material.dart';
import 'dart:io'; // FileImage uchun kerak
import 'package:orzulab/pages/login_page.dart';
import 'package:image_picker/image_picker.dart'; // Rasm tanlash uchun import
import 'package:orzulab/pages/my_orders_page.dart';
import 'package:orzulab/pages/my_comments_page.dart';
import 'package:orzulab/pages/payment_methods_page.dart';
import 'package:orzulab/pages/language_page.dart';
import 'package:orzulab/pages/location_page.dart';
import 'package:orzulab/pages/notification_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:orzulab/providers/auth_provider.dart';
import 'package:orzulab/pages/support_page.dart'; // Support sahifasini import qilish
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploading = false; // To indicate that the image is uploading

  // Logout function
  Future<void> _logout(BuildContext context) async {
    // Call the logout method via AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    // Close all pages and return to the Login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // Pastdan chiquvchi menyuni ko'rsatish uchun funksiya
  // Function to show the bottom sheet menu
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Profile Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text("Change profile picture"),
                onTap: () {
                  Navigator.pop(context); // Close the menu
                  _pickImage(); // Call the image picking function
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Speed up the upload by slightly reducing the image quality
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null && mounted) {
      setState(() { _isUploading = true; });
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        // Upload the image to the server via Provider
        await authProvider.updateProfilePicture(image);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated successfully!")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } finally {
        if (mounted) setState(() { _isUploading = false; });
      }
    }
  }

  // Function to launch email client for "Contact us"
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'orzulab1@gmail.com',
      query: 'subject=Support Request',
    );

    if (!await launchUrl(emailLaunchUri) && mounted) {
      // Show an error if the email client cannot be opened
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user data from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userProfile;
    // Safely get the data into separate variables.
    final phone = user?.phone;
    // Safely get the image URL into a separate variable.
    final profilePictureUrl = user?.profilePicture;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          // Header with profile info
          Container(
            color: const Color.fromARGB(255, 166, 166, 166),
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Row(
              children: [ 
                // Stack to show an indicator while the image is uploading
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      // TUZATISH: Rasm manziliga qarab NetworkImage yoki FileImage ishlatiladi
                      backgroundImage: profilePictureUrl != null
                          ? (profilePictureUrl.startsWith('http')
                              ? NetworkImage(profilePictureUrl) // Serverdan kelgan rasm uchun
                              : FileImage(File(profilePictureUrl)) as ImageProvider) // Mahalliy saqlangan rasm uchun
                          : null, // Rasm yo'q bo'lsa
                      backgroundColor: Colors.grey.shade400,
                      child: profilePictureUrl == null
                          ? const Icon(Icons.person, size: 35, color: Colors.white)
                          : null,
                    ),
                    if (_isUploading)
                      const CircularProgressIndicator(color: Colors.white),
                  ],
                ),
                const SizedBox(width: 20),
                // Expanded widget fixes overflow errors
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? "My Profile",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (phone != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            phone,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                // Changed the settings icon to be clickable
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    _showSettingsBottomSheet(context);
                  },
                ),
              ],
            ),
          ),

          // Menu section in a single Card
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  menuTile(Icons.shopping_bag, "My orders", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyOrdersPage()),
                    );
                  }),
                  menuTile(Icons.emoji_emotions, "My comments", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyCommentsPage()),
                    );
                  }),
                  menuTile(Icons.payment, "Payment", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentMethodsPage()),
                    );
                  }),
                  menuTile(Icons.notifications, "Notification", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationPage()),
                    );
                  }),
                  menuTile(Icons.language, "Language", onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const LanguagePage()));
                  }),
                  menuTile(Icons.location_on, "Location", onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const LocationPage()));
                  }),
                  menuTile(Icons.mail, "Contact us", onTap: _launchEmail),
                  menuTile(
                    Icons.support_agent,
                    "Support",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatSupportScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Exit button
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: () {
                // Logout logic added
                _logout(context);
              },
              child: const Text("Exit", style: TextStyle(fontSize: 16,color: Color.fromARGB(255, 255, 254, 254))),
            ),
          ),
        ],
      ),
    );
  }

  // onTap parameter added to the menuTile function
  Widget menuTile(IconData icon, String title, {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
