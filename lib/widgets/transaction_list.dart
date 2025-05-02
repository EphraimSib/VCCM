import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListWidget extends StatelessWidget {
  const TransactionListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/transaction-history');
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTransactionList(),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      {
        'title': 'Grocery Store',
        'amount': -45.20,
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': Icons.shopping_cart,
        'color': Colors.orange,
      },
      {
        'title': 'Salary Deposit',
        'amount': 2500.00,
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'icon': Icons.account_balance,
        'color': Colors.green,
      },
      {
        'title': 'Restaurant',
        'amount': -32.50,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'icon': Icons.restaurant,
        'color': Colors.red,
      },
      {
        'title': 'Transfer to Friend',
        'amount': -100.00,
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'icon': Icons.person,
        'color': Colors.blue,
      },
    ];

    return Column(
      children: transactions.map((transaction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: transaction['color'] as Color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  transaction['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(transaction['date'] as DateTime),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${(transaction['amount'] as double).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: (transaction['amount'] as double) < 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 