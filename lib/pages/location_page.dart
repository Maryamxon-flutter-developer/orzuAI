import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Logic to add a new address
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text('You have no saved addresses.', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}