import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          if (authVM.user == null) {
            return const Center(child: Text('User not found'));
          }

          final user = authVM.user!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _buildSettingsSection(
                  title: 'Account',
                  items: [
                    _SettingsItem(
                        icon: Icons.edit, label: 'Edit Profile', onTap: () {}),
                    _SettingsItem(
                        icon: Icons.security,
                        label: 'Change Password',
                        onTap: () {}),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingsSection(
                  title: 'Preferences',
                  items: [
                    _SettingsItem(
                        icon: Icons.notifications,
                        label: 'Notifications',
                        onTap: () {}),
                    _SettingsItem(
                        icon: Icons.language, label: 'Language', onTap: () {}),
                    _SettingsItem(
                        icon: Icons.dark_mode,
                        label: 'Dark Mode',
                        onTap: () {}),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingsSection(
                  title: 'Support',
                  items: [
                    _SettingsItem(
                        icon: Icons.help, label: 'Help Center', onTap: () {}),
                    _SettingsItem(
                        icon: Icons.info, label: 'About', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<AuthViewModel>().logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsSection(
      {required String title, required List<_SettingsItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
