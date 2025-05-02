import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/test_result_filter_provider.dart';
import '../../providers/beta_engagement_provider.dart';
import '../../providers/launch_readiness_provider.dart';

class TestingDashboardScreen extends StatelessWidget {
  const TestingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<TestResultFilterProvider>(context);
    final betaProvider = Provider.of<BetaEngagementProvider>(context);
    final launchProvider = Provider.of<LaunchReadinessProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Launch Readiness Status
            Card(
              child: ListTile(
                title: const Text('Launch Readiness'),
                trailing: Switch(
                  value: launchProvider.isLaunchReady,
                  onChanged: (value) {
                    launchProvider.setLaunchReady(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Result Filtering Options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filter Test Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: TestResultFilter.values.map((filter) {
                        final isSelected = filterProvider.currentFilter == filter;
                        return ChoiceChip(
                          label: Text(filter.name.toUpperCase()),
                          selected: isSelected,
                          onSelected: (_) {
                            filterProvider.setFilter(filter);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Beta Feedback Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Beta User Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (betaProvider.feedbackList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No feedback yet.'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: betaProvider.feedbackList.length,
                        itemBuilder: (context, index) {
                          final feedback = betaProvider.feedbackList[index];
                          return ListTile(
                            title: Text(feedback.feedback),
                            subtitle: Text('User: ${feedback.userId} - ${feedback.timestamp.toLocal()}'),
                            trailing: IconButton(
                              icon: Icon(
                                feedback.responded ? Icons.check_circle : Icons.mark_email_unread,
                                color: feedback.responded ? Colors.green : Colors.grey,
                              ),
                              onPressed: () {
                                betaProvider.markResponded(feedback.userId, feedback.timestamp);
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Multi-Device Insights Placeholder
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Multi-Device Testing Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Device-specific test data and performance metrics will be displayed here.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
