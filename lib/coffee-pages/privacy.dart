import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Introduction',
              'Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information.',
            ),
            _buildSection(
              '1. Information We Collect',
              'We collect personal information such as your name, email, and coffee consumption data when you use Coffee Tracker.',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use your data to enhance your experience, provide insights on caffeine intake, and improve our services.',
            ),
            _buildSection(
              '3. Data Security',
              'We implement security measures to protect your data. However, no method of transmission over the internet is 100% secure.',
            ),
            _buildSection(
              '4. Data Sharing',
              'We do not sell or share your personal data with third parties, except as required by law.',
            ),
            _buildSection(
              '5. Your Choices',
              'You can update or delete your data at any time through the app settings.',
            ),
            _buildSection(
              '6. Changes to This Policy',
              'We may update this Privacy Policy periodically. We will notify users of significant changes.',
            ),
            _buildSection(
              '7. Contact Us',
              'If you have any questions, please contact us at support@coffeetracker.com.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Last updated: March 2024',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
