// lib/src/pages/tabs/bill_details_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models.dart';

class BillDetailsPage extends StatelessWidget {
  final Bill bill;

  const BillDetailsPage({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);
    final dateFormat = DateFormat.yMMMd();

    // Calculate how many people the bill is split with.
    final numPeople = bill.splitWith.length;
    final splitAmount = bill.totalAmount / numPeople;

    return Scaffold(
      appBar: AppBar(
        title: Text(bill.description),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Total Amount
                Text(
                  currencyFormat.format(bill.totalAmount),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  bill.description,
                  style: theme.textTheme.titleLarge,
                ),
                const Divider(height: 32),

                // Bill Details
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: dateFormat.format(bill.date),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.person_outline,
                  label: 'Paid By',
                  value: bill.paidBy, // In a real app, you'd convert this ID to a name.
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.group_outlined,
                  label: 'Split Among',
                  value: '$numPeople people',
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.pie_chart_outline,
                  label: 'Amount Per Person',
                  value: currencyFormat.format(splitAmount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, textAlign: TextAlign.end)),
      ],
    );
  }
}
