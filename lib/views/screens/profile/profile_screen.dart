import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../../view_models/settings_viewmodel.dart';
import '../../../view_models/theme_viewmodel.dart';
import 'edit_profile_screen.dart';
import 'about_screen.dart';

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
                      icon: Icons.edit,
                      label: 'Edit Profile',
                      onTap: () =>
                          Navigator.of(context).pushNamed('/edit-profile'),
                    ),
                    _SettingsItem(
                      icon: Icons.security,
                      label: 'Change Password',
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer<SettingsViewModel>(
                  builder: (context, settings, _) =>
                      _buildPreferencesSection(context, settings),
                ),
                const SizedBox(height: 16),
                _buildSettingsSection(
                  title: 'Support',
                  items: [
                    _SettingsItem(
                      icon: Icons.help,
                      label: 'Help Center',
                      onTap: () => _showHelpDialog(context),
                    ),
                    _SettingsItem(
                      icon: Icons.info,
                      label: 'About',
                      onTap: () => Navigator.of(context).pushNamed('/about'),
                    ),
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

Widget _buildPreferencesSection(
    BuildContext context, SettingsViewModel settings) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Preferences',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Card(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Notifications'),
              value: settings.notifications,
              onChanged: (value) => settings.toggleNotifications(),
              secondary: const Icon(Icons.notifications),
            ),
            Consumer<ThemeViewModel>(
              builder: (context, themeVM, _) => SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeVM.currentMode == ThemeMode.dark,
                onChanged: (value) {
                  final newMode = value ? ThemeMode.dark : ThemeMode.light;
                  themeVM.setMode(newMode);
                  settings.toggleDarkMode();
                },
                secondary: const Icon(Icons.dark_mode),
              ),
            ),
            ListTile(
              title: const Text('Language'),
              subtitle: Text(settings.language.toUpperCase()),
              leading: const Icon(Icons.language),
              trailing: DropdownButton<String>(
                value: settings.language,
                underline: const SizedBox(),
                items: settings.supportedLanguages
                    .map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(_getLanguageName(lang)),
                        ))
                    .toList(),
                onChanged: (value) =>
                    value != null ? settings.setLanguage(value) : null,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

String _getLanguageName(String lang) {
  final names = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
  };
  return names[lang] ?? lang.toUpperCase();
}

void _showChangePasswordDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Change Password'),
      content: const Text('Password change feature coming soon.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void _showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Help Center'),
      content: const Text('Help and support coming soon.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
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
