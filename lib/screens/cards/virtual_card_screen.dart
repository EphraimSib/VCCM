import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class VirtualCardScreen extends StatefulWidget {
  const VirtualCardScreen({super.key});

  @override
  State<VirtualCardScreen> createState() => _VirtualCardScreenState();
}

class _VirtualCardScreenState extends State<VirtualCardScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isCardLocked = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      setState(() {
        _isBiometricEnabled = canAuthenticate;
      });
    } catch (e) {
      print('Error checking biometrics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Card'),
        actions: [
          IconButton(
            icon: Icon(_isCardLocked ? Icons.lock : Icons.lock_open),
            onPressed: _toggleCardLock,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCardSection(),
            const SizedBox(height: 24),
            _buildSecuritySection(),
            const SizedBox(height: 24),
            _buildTransactionLimitsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.indigo.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VCCM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                _isCardLocked ? Icons.lock : Icons.lock_open,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '**** **** **** 1234',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '12/25',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'CVV',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '***',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID for transactions'),
            value: _isBiometricEnabled,
            onChanged: (value) {
              setState(() {
                _isBiometricEnabled = value;
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Change PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Implement PIN change
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('View Security Log'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Implement security log view
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionLimitsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Limits',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildLimitTile(
            title: 'Daily Limit',
            current: '\$5,000',
            max: '\$10,000',
          ),
          const Divider(),
          _buildLimitTile(
            title: 'Single Transaction',
            current: '\$2,000',
            max: '\$5,000',
          ),
          const Divider(),
          _buildLimitTile(
            title: 'International',
            current: '\$1,000',
            max: '\$3,000',
          ),
        ],
      ),
    );
  }

  Widget _buildLimitTile({
    required String title,
    required String current,
    required String max,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text('Current: $current / Max: $max'),
      trailing: TextButton(
        onPressed: () {
          // Implement limit adjustment
        },
        child: const Text('Adjust'),
      ),
    );
  }

  Future<void> _toggleCardLock() async {
    if (_isCardLocked) {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock your virtual card',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        setState(() {
          _isCardLocked = false;
        });
      }
    } else {
      setState(() {
        _isCardLocked = true;
      });
    }
  }
} 