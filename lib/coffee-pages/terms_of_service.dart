import 'package:flutter/material.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service',
            style: TextStyle(color: Colors.white)),
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
              'Welcome to Coffee Tracker',
              'By using our app, you agree to these terms. Please read them carefully.',
            ),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using Coffee Tracker, you accept and agree to be bound by the terms and provisions of this agreement.',
            ),
            _buildSection(
              '2. App Usage',
              'Coffee Tracker is designed to help track caffeine intake. While we strive to provide accurate information, we cannot guarantee the accuracy of caffeine content calculations. The app should not be used as a medical tool.',
            ),
            _buildSection(
              '3. User Account',
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            _buildSection(
              '4. Privacy',
              'Your privacy is important to us. We collect and store only the information necessary to provide our services. Please refer to our Privacy Policy for more details.',
            ),
            _buildSection(
              '5. Data Storage',
              'We store your coffee consumption data to provide tracking services. You can delete your data at any time through the app interface.',
            ),
            _buildSection(
              '6. Health Disclaimer',
              'Coffee Tracker is not a medical app. The information and recommendations provided are for general informational purposes only. Always consult with a healthcare professional about your caffeine consumption.',
            ),
            _buildSection(
              '7. Modifications',
              'We reserve the right to modify these terms at any time. We will notify users of any material changes to these terms.',
            ),
            _buildSection(
              '8. Termination',
              'We reserve the right to terminate or suspend access to our services immediately, without prior notice or liability, for any reason.',
            ),
            _buildSection(
              '9. Limitation of Liability',
              'Coffee Tracker is provided "as is" without any warranties. We shall not be liable for any indirect, incidental, special, consequential, or punitive damages.',
            ),
            _buildSection(
              '10. Contact',
              'If you have any questions about these Terms, please contact us at support@coffeetracker.com',
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
