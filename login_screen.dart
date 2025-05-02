import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vccm/providers/user_provider.dart';
import 'package:vccm/widgets/transaction_analytics_stream.dart';
import 'package:vccm/widgets/adaptive_analytics_stream.dart';
import 'package:vccm/widgets/financial_metrics_stream.dart';
import 'package:vccm/services/subscription_service.dart';
import 'package:vccm/services/fee_management_service.dart';
import 'package:vccm/widgets/subscription_plans_widget.dart';
import 'package:vccm/services/advanced_analytics_service.dart';
import 'package:vccm/services/premium_analytics_service.dart';
import 'package:vccm/widgets/premium_features_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final subscriptionService = SubscriptionService();
    final feeService = FeeManagementService(subscriptionService);
    final analyticsService = AdvancedAnalyticsService(subscriptionService, feeService);
    final premiumService = PremiumAnalyticsService(analyticsService);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await Provider.of<UserProvider>(context, listen: false).login(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                },
                child: const Text('Login'),
              ),
              AdaptiveAnalyticsStream(
                analyticsService: adaptiveAnalyticsService,
                showDetails: true,
              ),
              SubscriptionPlansWidget(
                userId: currentUserId,
                subscriptionService: subscriptionService,
                feeService: feeService,
              ),
              FinancialMetricsStream(
                feeService: feeService,
                showDetails: true,
              ),
              PremiumFeaturesWidget(
                premiumService: premiumService,
                userId: currentUserId,
                showDetails: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}