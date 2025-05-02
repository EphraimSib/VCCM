import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum SecurityLevel {
  critical,
  warning,
  info,
  suspicious,
}

class SecurityAlert {
  final String title;
  final String message;
  final SecurityLevel level;
  final String? actionLabel;
  final DateTime timestamp;

  SecurityAlert({
    required this.title,
    required this.message,
    required this.level,
    this.actionLabel,
  }) : timestamp = DateTime.now();

  factory SecurityAlert.critical(String title, String message) {
    return SecurityAlert(
      title: title,
      message: message,
      level: SecurityLevel.critical,
      actionLabel: 'Take Action',
    );
  }

  factory SecurityAlert.warning(String title, String message) {
    return SecurityAlert(
      title: title,
      message: message,
      level: SecurityLevel.warning,
      actionLabel: 'Review',
    );
  }

  factory SecurityAlert.info(String title, String message) {
    return SecurityAlert(
      title: title,
      message: message,
      level: SecurityLevel.info,
    );
  }

  factory SecurityAlert.suspicious(String title, String message) {
    return SecurityAlert(
      title: title,
      message: message,
      level: SecurityLevel.suspicious,
      actionLabel: 'Verify',
    );
  }
}

class SecurityNotificationWidget extends StatelessWidget {
  final List<SecurityAlert> alerts;
  final Function(SecurityAlert) onAlertDismissed;
  final Function(SecurityAlert) onAlertActionPressed;

  const SecurityNotificationWidget({
    super.key,
    required this.alerts,
    required this.onAlertDismissed,
    required this.onAlertActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: alerts.map((alert) {
          return _buildAlertCard(context, alert)
              .animate()
              .fadeIn()
              .slideY(begin: -0.2, end: 0);
        }).toList(),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, SecurityAlert alert) {
    return Dismissible(
      key: Key('${alert.timestamp.millisecondsSinceEpoch}'),
      onDismissed: (_) => onAlertDismissed(alert),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: _getAlertColor(alert.level).withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getAlertColor(alert.level).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getAlertIcon(alert.level),
                    color: _getAlertColor(alert.level),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: TextStyle(
                        color: _getAlertColor(alert.level),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (alert.actionLabel != null)
                    TextButton(
                      onPressed: () => onAlertActionPressed(alert),
                      style: TextButton.styleFrom(
                        foregroundColor: _getAlertColor(alert.level),
                      ),
                      child: Text(alert.actionLabel!),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                alert.message,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTimestamp(alert.timestamp),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAlertColor(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.critical:
        return Colors.red.shade400;
      case SecurityLevel.warning:
        return Colors.orange.shade400;
      case SecurityLevel.info:
        return Colors.blue.shade400;
      case SecurityLevel.suspicious:
        return Colors.purple.shade400;
    }
  }

  IconData _getAlertIcon(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.critical:
        return Icons.error_outline;
      case SecurityLevel.warning:
        return Icons.warning_amber_rounded;
      case SecurityLevel.info:
        return Icons.info_outline;
      case SecurityLevel.suspicious:
        return Icons.security_outlined;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
} 