import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': '1',
      'type': 'expense',
      'amount': -50.00,
      'description': 'Grocery Store',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'category': 'Shopping',
    },
    {
      'id': '2',
      'type': 'income',
      'amount': 2000.00,
      'description': 'Salary Deposit',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'category': 'Salary',
    },
    {
      'id': '3',
      'type': 'expense',
      'amount': -30.00,
      'description': 'Restaurant',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'category': 'Food',
    },
    {
      'id': '4',
      'type': 'expense',
      'amount': -100.00,
      'description': 'Transfer to Friend',
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'category': 'Transfer',
    },
  ];

  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return _buildTransactionTile(transaction);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    final isExpense = transaction['type'] == 'expense';
    final amount = transaction['amount'] as double;
    final formattedDate = DateFormat('MMM dd, yyyy').format(transaction['date']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isExpense ? Icons.arrow_upward : Icons.arrow_downward,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          transaction['description'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$formattedDate • ${transaction['category']}',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Text(
          '\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: isExpense ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('All'),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value.toString();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Income'),
              value: 'income',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value.toString();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Expenses'),
              value: 'expense',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value.toString();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
} 