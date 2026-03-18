import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About LoopMind'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.psychology, size: 80, color: Color(0xFF6366F1)),
            SizedBox(height: 24),
            Text(
              'LoopMind',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your personal AI-powered task manager and reflection journal.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              '© 2026 LoopMind. All rights reserved.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Spacer(),
            Center(
              child: Text(
                'Made with ❤️ for productivity',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
