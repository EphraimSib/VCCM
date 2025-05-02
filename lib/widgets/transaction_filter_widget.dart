import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/transaction_filter_service.dart';

enum TransactionType { all, income, expense }
enum SortOrder { newest, oldest, highestAmount, lowestAmount }

class TransactionFilterWidget extends StatefulWidget {
  final Function(TransactionType, SortOrder, DateTimeRange?) onFilterChanged;
  final String userId;

  const TransactionFilterWidget({
    super.key,
    required this.onFilterChanged,
    required this.userId,
  });

  @override
  State<TransactionFilterWidget> createState() => _TransactionFilterWidgetState();
}

class _TransactionFilterWidgetState extends State<TransactionFilterWidget> with SingleTickerProviderStateMixin {
  TransactionType _selectedType = TransactionType.all;
  SortOrder _selectedOrder = SortOrder.newest;
  DateTimeRange? _selectedDateRange;
  late final TransactionFilterService _filterService;
  late final AnimationController _suggestionsController;
  List<FilterSuggestion> _suggestions = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filterService = TransactionFilterService();
    _suggestionsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadSuggestions();
  }

  @override
  void dispose() {
    _suggestionsController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    final suggestions = await _filterService.getSuggestedFilters(widget.userId);
    setState(() {
      _suggestions = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Transactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: _suggestionsController,
                      color: Colors.white,
                    ),
                    onPressed: _toggleExpanded,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                _buildTypeFilter(),
                const SizedBox(height: 16),
                _buildSortOrder(),
                const SizedBox(height: 16),
                _buildDateRange(context),
              ],
            ],
          ),
        ),
        if (_suggestions.isNotEmpty)
          _buildSuggestions()
              .animate()
              .fadeIn()
              .slideY(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade300.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.green.shade300,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Suggestions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              return _buildSuggestionChip(suggestion);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(FilterSuggestion suggestion) {
    return InkWell(
      onTap: () => _applySuggestion(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade300.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green.shade300.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getSuggestionIcon(suggestion.type),
              color: Colors.green.shade300,
              size: 16,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  suggestion.title,
                  style: TextStyle(
                    color: Colors.green.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  suggestion.description,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(
      target: 0.95,
      effects: [
        const ScaleEffect(
          duration: Duration(milliseconds: 150),
          curve: Curves.easeInOut,
        ),
      ],
    );
  }

  IconData _getSuggestionIcon(FilterType type) {
    switch (type) {
      case FilterType.category:
        return Icons.category;
      case FilterType.timeRange:
        return Icons.access_time;
      case FilterType.amount:
        return Icons.attach_money;
      case FilterType.location:
        return Icons.location_on;
    }
  }

  void _applySuggestion(FilterSuggestion suggestion) {
    // Implement suggestion application logic
    switch (suggestion.type) {
      case FilterType.category:
        // Apply category filter
        break;
      case FilterType.timeRange:
        // Apply time range filter
        break;
      case FilterType.amount:
        // Apply amount filter
        break;
      case FilterType.location:
        // Apply location filter
        break;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _suggestionsController.forward();
      } else {
        _suggestionsController.reverse();
      }
    });
  }

  Widget _buildTypeFilter() {
    return Row(
      children: [
        _filterChip(
          label: 'All',
          selected: _selectedType == TransactionType.all,
          onTap: () => _updateType(TransactionType.all),
        ),
        const SizedBox(width: 8),
        _filterChip(
          label: 'Income',
          selected: _selectedType == TransactionType.income,
          onTap: () => _updateType(TransactionType.income),
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _filterChip(
          label: 'Expense',
          selected: _selectedType == TransactionType.expense,
          onTap: () => _updateType(TransactionType.expense),
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSortOrder() {
    return DropdownButtonFormField<SortOrder>(
      value: _selectedOrder,
      dropdownColor: const Color(0xFF1A1F3D),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      style: const TextStyle(color: Colors.white),
      items: [
        DropdownMenuItem(
          value: SortOrder.newest,
          child: Text('Newest First', style: TextStyle(color: Colors.grey.shade300)),
        ),
        DropdownMenuItem(
          value: SortOrder.oldest,
          child: Text('Oldest First', style: TextStyle(color: Colors.grey.shade300)),
        ),
        DropdownMenuItem(
          value: SortOrder.highestAmount,
          child: Text('Highest Amount', style: TextStyle(color: Colors.grey.shade300)),
        ),
        DropdownMenuItem(
          value: SortOrder.lowestAmount,
          child: Text('Lowest Amount', style: TextStyle(color: Colors.grey.shade300)),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedOrder = value;
            widget.onFilterChanged(_selectedType, _selectedOrder, _selectedDateRange);
          });
        }
      },
    );
  }

  Widget _buildDateRange(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Colors.green.shade300,
                  onPrimary: Colors.white,
                  surface: const Color(0xFF1A1F3D),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _selectedDateRange = picked;
            widget.onFilterChanged(_selectedType, _selectedOrder, _selectedDateRange);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey.shade300,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _selectedDateRange != null
                  ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                  : 'Select Date Range',
              style: TextStyle(color: Colors.grey.shade300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (color ?? Colors.green.shade300).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (color ?? Colors.green.shade300)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? (color ?? Colors.green.shade300)
                : Colors.grey.shade300,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    ).animate(
      target: 0.95,
      effects: [
        const ScaleEffect(
          duration: Duration(milliseconds: 150),
          curve: Curves.easeInOut,
        ),
      ],
    );
  }

  void _updateType(TransactionType type) {
    setState(() {
      _selectedType = type;
      widget.onFilterChanged(_selectedType, _selectedOrder, _selectedDateRange);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 