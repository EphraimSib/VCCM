import 'package:flutter/material.dart';
import 'package:vccm/models/card_model.dart';

class CardWidget extends StatelessWidget {
  final VirtualCard card;

  const CardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.cardNumber,
              style: const TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CVV: ${card.cvv}',
                  style: const TextStyle(color: Colors.white)),
              Text('Exp: ${card.expiryDate}',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          Text('\$${card.balance.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}