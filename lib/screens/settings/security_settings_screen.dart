import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isBiometricEnabled = false;
  bool _isMFAEnabled = false;
  bool _isEncryptionEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Authentication',
              children: [
                _buildSettingTile(
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face ID to sign in',
                  icon: Icons.fingerprint,
                  trailing: Switch(
                    value: _isBiometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isBiometricEnabled = value;
                      });
                    },
                  ),
                ),
                _buildSettingTile(
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add an extra layer of security',
                  icon: Icons.security,
                  trailing: Switch(
                    value: _isMFAEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isMFAEnabled = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Privacy',
              children: [
                _buildSettingTile(
                  title: 'Transaction History',
                  subtitle: 'View and manage your transaction logs',
                  icon: Icons.history,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/transaction-history');
                  },
                ),
                _buildSettingTile(
                  title: 'Data Encryption',
                  subtitle: 'Enable end-to-end encryption',
                  icon: Icons.lock,
                  trailing: Switch(
                    value: _isEncryptionEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isEncryptionEnabled = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Account',
              children: [
                _buildSettingTile(
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  icon: Icons.password,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),
                _buildSettingTile(
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  icon: Icons.logout,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showSignOutDialog();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.signOut();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 