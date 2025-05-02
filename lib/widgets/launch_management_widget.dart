import 'package:flutter/material.dart';
import '../services/launch_management_service.dart';

class LaunchManagementWidget extends StatelessWidget {
  final LaunchManagementService launchService;
  final bool showDetails;
  final Function(String)? onChecklistItemTap;
  final Function(String)? onDeploymentStepTap;
  final Function(String)? onBetaUserInvite;

  const LaunchManagementWidget({
    super.key,
    required this.launchService,
    this.showDetails = false,
    this.onChecklistItemTap,
    this.onDeploymentStepTap,
    this.onBetaUserInvite,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLaunchStatus(),
          const SizedBox(height: 16),
          _buildLaunchChecklist(),
          if (showDetails) ...[
            const SizedBox(height: 16),
            _buildMarketingCampaigns(),
            const SizedBox(height: 16),
            _buildBetaEngagement(),
            const SizedBox(height: 16),
            _buildDeploymentSteps(),
            const SizedBox(height: 16),
            _buildPostLaunchMetrics(),
          ],
        ],
      ),
    );
  }

  Widget _buildLaunchStatus() {
    return StreamBuilder<List<ChecklistItem>>(
      stream: launchService.checklistStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!;
        final completed = items.where((item) => item.status == ChecklistItemStatus.completed).length;
        final total = items.length;
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
                      'LAUNCH READINESS',
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
                      '$completed of $total tasks completed',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (progress == 1.0)
                      const Chip(
                        label: Text('Ready for Launch'),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLaunchChecklist() {
    return StreamBuilder<List<ChecklistItem>>(
      stream: launchService.checklistStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LAUNCH CHECKLIST',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => launchService.checklistStream,
                      tooltip: 'Refresh Checklist',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: _getChecklistColor(item.status).withOpacity(0.1),
                      child: InkWell(
                        onTap: () => onChecklistItemTap?.call(item.id),
                        child: ListTile(
                          leading: Icon(
                            _getChecklistIcon(item.status),
                            color: _getChecklistColor(item.status),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: _getChecklistColor(item.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.description),
                              if (item.notes != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Notes: ${item.notes}',
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (item.completedAt != null)
                                Text(
                                  _formatDate(item.completedAt!),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
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

  Widget _buildMarketingCampaigns() {
    return StreamBuilder<List<MarketingCampaign>>(
      stream: launchService.marketingStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final campaigns = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MARKETING CAMPAIGNS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = campaigns[index];
                    final progress = _calculateCampaignProgress(campaign);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.campaign, color: Colors.blue),
                            title: Text(
                              campaign.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(campaign.description),
                                const SizedBox(height: 4),
                                Text(
                                  'Channels: ${campaign.channels.join(', ')}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Budget: \$${campaign.budget.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start: ${_formatDate(campaign.startDate)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'End: ${_formatDate(campaign.endDate)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            color: _getProgressColor(progress),
                          ),
                        ],
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

  Widget _buildBetaEngagement() {
    return StreamBuilder<List<BetaEngagement>>(
      stream: launchService.betaStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final engagements = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'BETA ENGAGEMENT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Invite Beta Users'),
                      onPressed: () => onBetaUserInvite?.call(''),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (engagements.isEmpty)
                  const Center(
                    child: Text(
                      'No beta users yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: engagements.length,
                    itemBuilder: (context, index) {
                      final engagement = engagements[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.2),
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                          title: Text(
                            'Tier: ${engagement.tier}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perks: ${engagement.perks.join(', ')}',
                              ),
                              Text(
                                'Discount: ${(engagement.discount * 100).toStringAsFixed(0)}%',
                              ),
                              Text(
                                'Referrals: ${engagement.referralCount}',
                              ),
                              if (engagement.feedbackCategories.isNotEmpty)
                                Wrap(
                                  spacing: 4,
                                  children: engagement.feedbackCategories
                                      .map((category) => Chip(
                                            label: Text(category),
                                            backgroundColor: Colors.blue.withOpacity(0.1),
                                          ))
                                      .toList(),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatDate(engagement.joinedAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (engagement.referralCount > 0)
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
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

  Widget _buildDeploymentSteps() {
    return StreamBuilder<List<DeploymentStep>>(
      stream: launchService.deploymentStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final steps = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DEPLOYMENT STEPS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: _getChecklistColor(step.status).withOpacity(0.1),
                      child: InkWell(
                        onTap: () => onDeploymentStepTap?.call(step.id),
                        child: ListTile(
                          leading: Icon(
                            _getChecklistIcon(step.status),
                            color: _getChecklistColor(step.status),
                          ),
                          title: Text(
                            step.title,
                            style: TextStyle(
                              color: _getChecklistColor(step.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step.description),
                              if (step.output != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Output: ${step.output}',
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                step.isAutomated
                                    ? Icons.auto_fix_high
                                    : Icons.engineering,
                                color: Colors.grey,
                              ),
                              if (step.completedAt != null)
                                Text(
                                  _formatDate(step.completedAt!),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
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

  Widget _buildPostLaunchMetrics() {
    return StreamBuilder<List<PostLaunchMetric>>(
      stream: launchService.metricsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final metrics = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'POST-LAUNCH METRICS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: metrics.map((metric) {
                    final progress = (metric.value / metric.target).clamp(0.0, 1.0);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              metric.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              color: _getProgressColor(progress),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${metric.value.toStringAsFixed(1)} / ${metric.target.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              metric.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (metric.details.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...metric.details.entries.map((entry) => Text(
                                    '${entry.key}: ${entry.value}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  )),
                            ],
                          ],
                        ),
                      ),
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

  Color _getChecklistColor(ChecklistItemStatus status) {
    switch (status) {
      case ChecklistItemStatus.completed:
        return Colors.green;
      case ChecklistItemStatus.inProgress:
        return Colors.orange;
      case ChecklistItemStatus.failed:
        return Colors.red;
      case ChecklistItemStatus.pending:
        return Colors.grey;
    }
  }

  IconData _getChecklistIcon(ChecklistItemStatus status) {
    switch (status) {
      case ChecklistItemStatus.completed:
        return Icons.check_circle;
      case ChecklistItemStatus.inProgress:
        return Icons.hourglass_empty;
      case ChecklistItemStatus.failed:
        return Icons.error;
      case ChecklistItemStatus.pending:
        return Icons.radio_button_unchecked;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.9) return Colors.green;
    if (progress >= 0.7) return Colors.orange;
    return Colors.red;
  }

  double _calculateCampaignProgress(MarketingCampaign campaign) {
    final now = DateTime.now();
    if (now.isBefore(campaign.startDate)) return 0.0;
    if (now.isAfter(campaign.endDate)) return 1.0;
    
    final totalDuration = campaign.endDate.difference(campaign.startDate).inSeconds;
    final elapsedDuration = now.difference(campaign.startDate).inSeconds;
    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 