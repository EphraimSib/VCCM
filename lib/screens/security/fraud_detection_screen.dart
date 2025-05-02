import 'package:flutter/material.dart';

class FraudDetectionScreen extends StatefulWidget {
  const FraudDetectionScreen({super.key});

  @override
  State<FraudDetectionScreen> createState() => _FraudDetectionScreenState();
}

class _FraudDetectionScreenState extends State<FraudDetectionScreen> {
  final List<Map<String, dynamic>> _securityAlerts = [
    {
      'type': 'suspicious_login',
      'title': 'Suspicious Login Attempt',
      'description': 'Login attempt from new device in New York',
      'time': '2 minutes ago',
      'severity': 'high',
    },
    {
      'type': 'unusual_transaction',
      'title': 'Unusual Transaction Pattern',
      'description': 'Multiple transactions in different countries',
      'time': '15 minutes ago',
      'severity': 'medium',
    },
    {
      'type': 'card_usage',
      'title': 'Card Usage Alert',
      'description': 'Card used in new location',
      'time': '1 hour ago',
      'severity': 'low',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to security settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSecurityStatus(),
            const SizedBox(height: 24),
            _buildAlertsSection(),
            const SizedBox(height: 24),
            _buildSecurityFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatus() {
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
            'Security Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Systems Secure',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No critical security issues detected',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Security Alerts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all alerts
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._securityAlerts.map((alert) {
            return _buildAlertTile(alert);
          }),
        ],
      ),
    );
  }

  Widget _buildAlertTile(Map<String, dynamic> alert) {
    Color severityColor;
    switch (alert['severity']) {
      case 'high':
        severityColor = Colors.red;
        break;
      case 'medium':
        severityColor = Colors.orange;
        break;
      case 'low':
        severityColor = Colors.yellow;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAlertIcon(alert['type']),
              color: severityColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert['description'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert['time'],
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              // View alert details
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeatures() {
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
            'Security Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureTile(
            icon: Icons.location_on,
            title: 'Location Tracking',
            description: 'Monitor card usage locations',
            isEnabled: true,
          ),
          const Divider(),
          _buildFeatureTile(
            icon: Icons.notifications,
            title: 'Real-time Alerts',
            description: 'Get instant notifications',
            isEnabled: true,
          ),
          const Divider(),
          _buildFeatureTile(
            icon: Icons.lock,
            title: 'Transaction Lock',
            description: 'Lock card for specific transactions',
            isEnabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
    required bool isEnabled,
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
      title: Text(title),
      subtitle: Text(description),
      trailing: Switch(
        value: isEnabled,
        onChanged: (value) {
          // Implement feature toggle
        },
      ),
    );
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'suspicious_login':
        return Icons.warning;
      case 'unusual_transaction':
        return Icons.attach_money;
      case 'card_usage':
        return Icons.credit_card;
      default:
        return Icons.info;
    }
  }
} 