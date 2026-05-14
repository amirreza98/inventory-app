import 'package:flutter/material.dart';

class SupplierCard extends StatelessWidget {
  final String name;
  final String capital;
  final String flagUrl;
  final String currency;
  final String annualVolume;

  const SupplierCard({
    super.key,
    required this.name,
    required this.capital,
    required this.flagUrl,
    required this.currency,
    required this.annualVolume,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            flagUrl,
            width: 50,
            height: 36,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 50,
                height: 36,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stack) => const Icon(Icons.flag, size: 36),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('HQ: $capital'),
            Text('Currency: $currency'),
            Text('Annual Volume: $annualVolume'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
