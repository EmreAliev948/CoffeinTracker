import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'terms_of_service.dart';
import 'privacy.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _darkMode = false;
  bool _notifications = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.brown,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              currentUser?.email ?? 'User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildSettingSection(
              title: 'Appearance',
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() => _darkMode = value);
                  },
                ),
              ],
            ),
            _buildSettingSection(
              title: 'Notifications',
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: _notifications,
                  onChanged: (value) {
                    setState(() => _notifications = value);
                  },
                ),
              ],
            ),
            _buildSettingSection(
              title: 'Language',
              children: [
                ListTile(
                  title: const Text('Select Language'),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: ['English', 'Bulgarian'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedLanguage = newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
            _buildSettingSection(
              title: 'Support',
              children: [
                _buildProfileOption(
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () {
                    // Implement help & support
                  },
                ),
                _buildProfileOption(
                  icon: Icons.security,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyPolicy()),
                    );
                  },
                ),
                _buildProfileOption(
                  icon: Icons.description,
                  title: 'Terms of Service',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TermsOfService()),
                    );
                  },
                ),
              ],
            ),
            _buildSettingSection(
              title: 'About',
              children: [
                const ListTile(
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade700,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
