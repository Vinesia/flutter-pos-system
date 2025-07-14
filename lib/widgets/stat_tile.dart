import 'package:flutter/material.dart';

class StatTile extends StatelessWidget {
  final StatItem stat;

  const StatTile({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: stat.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: stat.color.withOpacity(0.2),
            child: Icon(stat.icon, color: stat.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stat.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Rp ${stat.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatItem {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  StatItem(this.title, this.amount, this.icon, this.color);
}
