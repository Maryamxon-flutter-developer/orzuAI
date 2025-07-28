import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          // Header with profile info
          Container(
            color: const Color.fromARGB(255, 166, 166, 166),
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=47',
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Lily Collins",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "+998 99 1234567",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.settings, color: Colors.white),
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
                  menuTile(Icons.shopping_bag, "My orders"),
                  menuTile(Icons.emoji_emotions, "My comments"),
                  menuTile(Icons.payment, "Payment"),
                  menuTile(Icons.notifications, "Notification"),
                  menuTile(Icons.settings, "Settings"),
                  menuTile(Icons.language, "Language"),
                  menuTile(Icons.location_on, "Location"),
                  menuTile(Icons.mail, "Contact us"),
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
              onPressed: () {},
              child: const Text("Exit", style: TextStyle(fontSize: 16,color: Color.fromARGB(255, 255, 254, 254))),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuTile(IconData icon, String title) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 1),
      ],
    );
  }
}
