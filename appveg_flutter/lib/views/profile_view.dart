import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthController>(
        builder: (context, controller, _) {
          if (!controller.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please login to view your profile'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          final user = controller.currentUser!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        child: user.profileImageUrl == null
                            ? Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(fontSize: 32),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildProfileSection(
                  context,
                  'Account Settings',
                  [
                    _buildListTile(
                      context,
                      'Edit Profile',
                      Icons.person,
                      onTap: () {
                        // TODO: Implement edit profile
                      },
                    ),
                    _buildListTile(
                      context,
                      'Change Password',
                      Icons.lock,
                      onTap: () {
                        // TODO: Implement change password
                      },
                    ),
                    _buildListTile(
                      context,
                      'Notifications',
                      Icons.notifications,
                      onTap: () {
                        // TODO: Implement notifications settings
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProfileSection(
                  context,
                  'App Settings',
                  [
                    _buildListTile(
                      context,
                      'Language',
                      Icons.language,
                      onTap: () {
                        // TODO: Implement language settings
                      },
                    ),
                    _buildListTile(
                      context,
                      'Dark Mode',
                      Icons.dark_mode,
                      onTap: () {
                        // TODO: Implement dark mode toggle
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProfileSection(
                  context,
                  'Support',
                  [
                    _buildListTile(
                      context,
                      'Help Center',
                      Icons.help,
                      onTap: () {
                        // TODO: Implement help center
                      },
                    ),
                    _buildListTile(
                      context,
                      'Privacy Policy',
                      Icons.privacy_tip,
                      onTap: () {
                        // TODO: Implement privacy policy
                      },
                    ),
                    _buildListTile(
                      context,
                      'Terms of Service',
                      Icons.description,
                      onTap: () {
                        // TODO: Implement terms of service
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    await controller.logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
