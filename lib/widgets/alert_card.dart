import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String name;
  final int qty;
  final int min;
  final bool isOutOfStock;
  final VoidCallback onTap;

  const AlertCard({
    super.key,
    required this.name,
    required this.qty,
    required this.min,
    required this.isOutOfStock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOutOfStock ? Colors.red : Colors.amber;

    return Card(
      margin: const EdgeInsets.only(top: 10),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  isOutOfStock
                      ? 'Stock: 0 — completely out of stock'
                      : 'Stock: $qty (min: $min)',
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOutOfStock ? 'OUT OF STOCK' : 'LOW STOCK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}
