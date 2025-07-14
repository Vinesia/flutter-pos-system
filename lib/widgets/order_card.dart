import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        backgroundColor: Colors.brown[50],
        leading: const Icon(Icons.receipt_long),
        title: Text(order['name'] ?? 'Tanpa Nama'),
        subtitle: Text(
          'Total: Rp ${order['total'] ?? 0} - Kategori: ${order['category'] ?? '-'}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Susu: ${order['milk']}'),
                Text('Extras: ${(order['extras'] as List?)?.join(', ') ?? '-'}'),
                const SizedBox(height: 6),
                Text('Items:'),
                ...(order['items'] as Map<String, dynamic>).entries.map((e) {
                  return Text('- ${e.key} x${e.value}');
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
