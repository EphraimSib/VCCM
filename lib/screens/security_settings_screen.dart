import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricEnabled = false;
  bool _mfaEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _biometricEnabled = canCheckBiometrics && isDeviceSupported;
      });
    } catch (e) {
      print('Error checking biometrics: $e');
    }
  }

  Future<void> _toggleBiometricAuth() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        setState(() {
          _biometricEnabled = !_biometricEnabled;
        });
      }
    } catch (e) {
      print('Error toggling biometric auth: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Authentication',
            children: [
              _buildSettingItem(
                title: 'Biometric Authentication',
                subtitle: 'Use fingerprint or face ID for quick access',
                trailing: Switch(
                  value: _biometricEnabled,
                  onChanged: (value) => _toggleBiometricAuth(),
                ),
              ),
              _buildSettingItem(
                title: 'QuantumShield MFA',
                subtitle: 'Enable multi-factor authentication',
                trailing: Switch(
                  value: _mfaEnabled,
                  onChanged: (value) {
                    setState(() {
                      _mfaEnabled = value;
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
              _buildSettingItem(
                title: 'Transaction History',
                subtitle: 'View and manage your transaction history',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/transaction-history');
                },
              ),
              _buildSettingItem(
                title: 'Data Privacy',
                subtitle: 'Manage your data privacy settings',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/privacy-settings');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Security',
            children: [
              _buildSettingItem(
                title: 'Change PIN',
                subtitle: 'Update your security PIN',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/change-pin');
                },
              ),
              _buildSettingItem(
                title: 'Security Alerts',
                subtitle: 'Manage security notifications',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/security-alerts');
                },
              ),
            ],
          ),
        ],
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
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

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
} 