import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/credit_card_widget.dart';
import '../../widgets/spending_graph_widget.dart';
import '../../widgets/financial_insights_widget.dart';
import '../../widgets/transaction_filter_widget.dart';
import '../../widgets/security_notification_widget.dart';
import '../../services/transaction_filter_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  TransactionType _selectedTransactionType = TransactionType.all;
  SortOrder _selectedSortOrder = SortOrder.newest;
  DateTimeRange? _selectedDateRange;
  final List<SecurityAlert> _securityAlerts = [
    SecurityAlert.suspicious(
      'Unusual Login Attempt',
      'We detected a login attempt from a new device in London. Was this you?',
    ),
    SecurityAlert.critical(
      'Large Transaction Alert',
      'A transaction of \$5,000 was initiated. Please verify this activity.',
    ),
  ];
  late final TransactionFilterService _filterService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _filterService = TransactionFilterService();
    _setupSecurityAlerts();
  }

  void _setupSecurityAlerts() {
    _filterService.securityAlerts.listen((alert) {
      setState(() {
        _securityAlerts.insert(0, alert);
      });
      _showSecurityNotification(alert);
    });
  }

  void _showSecurityNotification(SecurityAlert alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 5),
        action: alert.actionLabel != null
            ? SnackBarAction(
                label: alert.actionLabel!,
                textColor: Colors.white,
                onPressed: () => _onAlertActionPressed(alert),
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _filterService.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _onFilterChanged(TransactionType type, SortOrder order, DateTimeRange? range) {
    setState(() {
      _selectedTransactionType = type;
      _selectedSortOrder = order;
      _selectedDateRange = range;
    });
  }

  void _onAlertDismissed(SecurityAlert alert) {
    setState(() {
      _securityAlerts.remove(alert);
    });
  }

  void _onAlertActionPressed(SecurityAlert alert) async {
    // Handle alert action based on type
    switch (alert.level) {
      case SecurityLevel.critical:
        await _handleCriticalAlert(alert);
        break;
      case SecurityLevel.warning:
        await _handleWarningAlert(alert);
        break;
      case SecurityLevel.info:
        _handleInfoAlert(alert);
        break;
      case SecurityLevel.suspicious:
        // Handle suspicious alert if needed
        _handleInfoAlert(alert);
        break;
    }
  }

  Future<void> _handleCriticalAlert(SecurityAlert alert) async {
    // Show immediate action dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3D),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text(
              'Critical Security Alert',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          alert.message,
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: const Text('Take Action'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Implement critical action
      print('Taking action on critical alert: ${alert.title}');
    }
  }

  Future<void> _handleWarningAlert(SecurityAlert alert) async {
    // Show warning dialog with options
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3D),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade400),
            const SizedBox(width: 8),
            const Text(
              'Security Warning',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          alert.message,
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('dismiss'),
            child: const Text('Dismiss'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('review'),
            child: const Text('Review Activity'),
          ),
        ],
      ),
    );

    if (result == 'review') {
      // Navigate to activity review
      print('Reviewing activity for warning: ${alert.title}');
    }
  }

  void _handleInfoAlert(SecurityAlert alert) {
    // Show info notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(alert.message),
        backgroundColor: Colors.blue.shade900,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3D),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: _isScrolled ? 4 : 0,
            backgroundColor: const Color(0xFF1A1F3D),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Welcome back, ${Provider.of<UserProvider>(context).user?.displayName ?? 'User'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade400.withOpacity(0.2),
                      Colors.blue.shade400.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.green.shade300,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Transactions'),
                Tab(text: 'Insights'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildTransactionsTab(),
            _buildInsightsTab(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildOverviewTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return _buildWideOverviewLayout();
        } else if (constraints.maxWidth > 600) {
          return _buildMediumOverviewLayout();
        } else {
          return _buildNarrowOverviewLayout();
        }
      },
    );
  }

  Widget _buildWideOverviewLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SecurityNotificationWidget(
            alerts: _securityAlerts,
            onAlertDismissed: _onAlertDismissed,
            onAlertActionPressed: _onAlertActionPressed,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const CreditCardWidget()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 600))
                        .slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 24),
                    const SpendingGraphWidget()
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 400))
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: const FinancialInsightsWidget()
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 200))
                    .slideX(begin: 0.2, end: 0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediumOverviewLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SecurityNotificationWidget(
            alerts: _securityAlerts,
            onAlertDismissed: _onAlertDismissed,
            onAlertActionPressed: _onAlertActionPressed,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: const CreditCardWidget()
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 600))
                    .slideX(begin: -0.2, end: 0),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: const SpendingGraphWidget()
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 400))
                    .slideY(begin: 0.2, end: 0),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const FinancialInsightsWidget()
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 200))
              .slideX(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildNarrowOverviewLayout() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SecurityNotificationWidget(
          alerts: _securityAlerts,
          onAlertDismissed: _onAlertDismissed,
          onAlertActionPressed: _onAlertActionPressed,
        ),
        const CreditCardWidget()
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideX(begin: -0.2, end: 0),
        const SizedBox(height: 24),
        const SpendingGraphWidget()
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 400))
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 24),
        const FinancialInsightsWidget()
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 200))
            .slideX(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TransactionFilterWidget(
            onFilterChanged: _onFilterChanged,
            userId: Provider.of<UserProvider>(context).user?.uid ?? '',
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 10, // Replace with actual transaction count
            itemBuilder: (context, index) {
              return _buildTransactionItem(index)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 100 * index))
                  .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(int index) {
    // Sample transaction data
    final isExpense = index % 2 == 0;
    final amount = isExpense ? -42.50 : 125.00;
    final category = isExpense ? 'Shopping' : 'Income';
    final date = DateTime.now().subtract(Duration(days: index));

    // Apply filters
    if (_selectedTransactionType != TransactionType.all) {
      if (_selectedTransactionType == TransactionType.income && isExpense) {
        return const SizedBox.shrink();
      }
      if (_selectedTransactionType == TransactionType.expense && !isExpense) {
        return const SizedBox.shrink();
      }
    }

    if (_selectedDateRange != null) {
      if (date.isBefore(_selectedDateRange!.start) ||
          date.isAfter(_selectedDateRange!.end)) {
        return const SizedBox.shrink();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense ? Icons.remove : Icons.add,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: isExpense ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const FinancialInsightsWidget()
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Show quick action menu
      },
      backgroundColor: Colors.green.shade400,
      child: const Icon(Icons.add),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(1.1, 1.1),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
    );
  }
} 