import 'package:flutter/material.dart';
import '../services/testing_service.dart';

class TestingDashboardWidget extends StatelessWidget {
  final TestingService testingService;
  final bool showDetails;

  const TestingDashboardWidget({
    super.key,
    required this.testingService,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTestResults(),
          if (showDetails) ...[
            const SizedBox(height: 16),
            _buildPerformanceTests(),
            const SizedBox(height: 16),
            _buildSecurityTests(),
            const SizedBox(height: 16),
            _buildUITests(),
            const SizedBox(height: 16),
            _buildCompatibilityTests(),
            const SizedBox(height: 16),
            _buildBetaFeedback(),
          ],
        ],
      ),
    );
  }

  Widget _buildTestResults() {
    return StreamBuilder<List<TestResult>>(
      stream: testingService.testResultsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data!;
        final completed = results.where((result) => result.status == TestStatus.completed).length;
        final total = results.length;
        final progress = completed / total;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TESTING OVERVIEW',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(progress),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: _getProgressColor(progress),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completed of $total tests completed',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (progress == 1.0)
                      const Chip(
                        label: Text('All Tests Passed'),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TestType.values.map((type) {
                    final count = results.where((result) => result.type == type).length;
                    final completed = results
                        .where((result) => result.type == type && result.status == TestStatus.completed)
                        .length;
                    return Chip(
                      label: Text('${type.toString().split('.').last}: $completed/$count'),
                      backgroundColor: _getTestTypeColor(type).withOpacity(0.1),
                      labelStyle: TextStyle(color: _getTestTypeColor(type)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceTests() {
    return StreamBuilder<List<PerformanceTest>>(
      stream: testingService.performanceTestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tests = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PERFORMANCE TESTS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.speed, color: Colors.blue),
                        title: Text(
                          test.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transactions: ${test.transactionCount}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Users: ${test.concurrentUsers}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Duration: ${test.duration.inMinutes} minutes',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (test.results.isNotEmpty) ...[
                              Text(
                                'Response: ${test.results['responseTime']?.toStringAsFixed(2)}ms',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Throughput: ${test.results['throughput']}/s',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityTests() {
    return StreamBuilder<List<SecurityTest>>(
      stream: testingService.securityTestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tests = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SECURITY TESTS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.security,
                          color: test.riskScore > 50 ? Colors.red : Colors.green,
                        ),
                        title: Text(
                          test.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Risk Score: ${test.riskScore}',
                              style: TextStyle(
                                color: test.riskScore > 50 ? Colors.red : Colors.green,
                              ),
                            ),
                            if (test.vulnerabilities.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: test.vulnerabilities
                                    .map((vuln) => Chip(
                                          label: Text(vuln),
                                          backgroundColor: Colors.red.withOpacity(0.1),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (test.recommendations.isNotEmpty)
                              const Icon(
                                Icons.warning,
                                color: Colors.orange,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUITests() {
    return StreamBuilder<List<UITest>>(
      stream: testingService.uiTestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tests = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UI TESTS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    final passed = test.results['testCasesPassed'] ?? 0;
                    final total = test.results['totalTestCases'] ?? test.testCases.length;
                    final progress = passed / total;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.phone_android,
                          color: progress == 1.0 ? Colors.green : Colors.orange,
                        ),
                        title: Text(
                          test.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Test Cases: $passed/$total',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (test.results.isNotEmpty) ...[
                              Text(
                                'Render Time: ${test.results['renderTime']?.toStringAsFixed(2)}ms',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'FPS: ${test.results['animationFPS']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                            if (test.issues.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: test.issues
                                    .map((issue) => Chip(
                                          label: Text(issue),
                                          backgroundColor: Colors.orange.withOpacity(0.1),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompatibilityTests() {
    return StreamBuilder<List<CompatibilityTest>>(
      stream: testingService.compatibilityTestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tests = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMPATIBILITY TESTS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    final successRate = test.results['successRate'] ?? 0.0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.devices,
                          color: successRate >= 90 ? Colors.green : Colors.orange,
                        ),
                        title: Text(
                          test.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Devices: ${test.devices.join(', ')}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Platforms: ${test.platforms.join(', ')}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (test.results.isNotEmpty) ...[
                              Text(
                                'Success Rate: ${successRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: successRate >= 90 ? Colors.green : Colors.orange,
                                ),
                              ),
                              Text(
                                'Load Time: ${test.results['averageLoadTime']?.toStringAsFixed(2)}ms',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                            if (test.issues.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: test.issues
                                    .map((issue) => Chip(
                                          label: Text(issue),
                                          backgroundColor: Colors.orange.withOpacity(0.1),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBetaFeedback() {
    return StreamBuilder<List<BetaFeedback>>(
      stream: testingService.betaFeedbackStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedback = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BETA FEEDBACK',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (feedback.isEmpty)
                  const Center(
                    child: Text(
                      'No feedback yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: feedback.length,
                    itemBuilder: (context, index) {
                      final item = feedback[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.2),
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                          title: Text(
                            'Rating: ${item.rating}/5',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.feedback),
                              if (item.categories.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: item.categories
                                      .map((category) => Chip(
                                            label: Text(category),
                                            backgroundColor: Colors.blue.withOpacity(0.1),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                          trailing: Text(
                            _formatDate(item.submittedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.9) return Colors.green;
    if (progress >= 0.7) return Colors.orange;
    return Colors.red;
  }

  Color _getTestTypeColor(TestType type) {
    switch (type) {
      case TestType.performance:
        return Colors.blue;
      case TestType.security:
        return Colors.red;
      case TestType.ui:
        return Colors.purple;
      case TestType.compatibility:
        return Colors.orange;
      case TestType.feedback:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 