import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../../view_models/task_viewmodel.dart';
import '../../../view_models/theme_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Consumer2<AuthViewModel, TaskViewModel>(
          builder: (context, authVM, taskVM, _) {
            final user = authVM.user;
            if (user == null) {
              return const Center(child: Text('Loading profile...'));
            }

            return RefreshIndicator(
              onRefresh: () => authVM.checkAuthStatus(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user.email.isNotEmpty
                            ? user.email[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.email,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text('XP: ${user.xpPoints}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.green)),
                    ElevatedButton(
                      onPressed: () => authVM.checkAuthStatus(),
                      child: const Text('Refresh Stats'),
                    ),
                    const SizedBox(height: 24),
                    _buildStatsCard(context, user),
                    const SizedBox(height: 24),
                    _buildSettingsSection('Account', [
                      _SettingsItem(
                          icon: Icons.edit,
                          label: 'Edit Profile',
                          onTap: () =>
                              Navigator.pushNamed(context, '/edit-profile')),
                    ]),
                    const SizedBox(height: 16),
                    _buildPreferencesSection(context),
                    const SizedBox(height: 16),
                    _buildSettingsSection('Support', [
                      _SettingsItem(
                          icon: Icons.help, label: 'Help', onTap: () {}),
                      _SettingsItem(
                          icon: Icons.info,
                          label: 'About',
                          onTap: () => Navigator.pushNamed(context, '/about')),
                    ]),
                    const SizedBox(height: 24),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Logout'),
                        onPressed: () {
                          authVM.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, UserModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _statItem(
                        'Current Streak', '${user.currentStreak} Tasks')),
                Expanded(
                    child: _statItem(
                        'Best Streak', '${user.longestStreak} Tasks')),
              ],
            ),
            const SizedBox(height: 8),
            _statItem('Total XP', '${user.xpPoints} points'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(child: Column(children: items)),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                  title: const Text('Notifications'),
                  value: true,
                  onChanged: (_) {}),
              Consumer<ThemeViewModel>(
                builder: (context, themeVM, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: themeVM.currentMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeVM.setMode(value ? ThemeMode.dark : ThemeMode.light);
                    },
                    secondary: const Icon(Icons.dark_mode),
                  );
                },
              ),
            ],
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
        onTap: onTap);
  }
}
