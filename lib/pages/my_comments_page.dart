import 'package:flutter/material.dart';

class MyCommentsPage extends StatelessWidget {
  const MyCommentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Comments'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment_bank_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text('You have not left any comments yet.', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}