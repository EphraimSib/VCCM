import 'package:flutter/material.dart';
import '../widgets/virtual_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Testing Dashboard',
            onPressed: () {
              Navigator.pushNamed(context, '/testing-dashboard');
            },
          ),
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () {
              Navigator.pushNamed(context, '/security-settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Virtual Card',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              VirtualCard(
                cardNumber: '**** **** **** 1234',
                cardHolder: 'John Doe',
                expiryDate: '12/25',
                cvv: '123',
                onTap: () {
                  Navigator.pushNamed(context, '/payment');
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Balance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$5,000.00',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.account_balance_wallet,
                      size: 32,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.shopping_bag),
                    ),
                    title: Text('Transaction ${index + 1}'),
                    subtitle: Text('Today, ${index + 1}:00 PM'),
                    trailing: Text(
                      '\$${(index + 1) * 100}.00',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/payment');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
