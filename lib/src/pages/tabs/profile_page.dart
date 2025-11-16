// lib/src/pages/tabs/profile_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models.dart';
import '../../state/app_state.dart';
import '../../widgets/poke_background.dart';
import '../../widgets/rename_dialog.dart'; // Import the new dialog

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // --- NEW: Function to calculate money owed ---
  Map<String, double> _calculateOwedMoney(AppState appState) {
    double iOwe = 0;
    double othersOweMe = 0;
    final myId = appState.userId;

    for (final bill in appState.bills) {
      final numPeople = bill.splitWith.length > 0 ? bill.splitWith.length : 1;
      final perPersonAmount = bill.totalAmount / numPeople;

      if (bill.paidBy == myId) {
        // I paid for the bill
        for (final memberId in bill.splitWith) {
          if (memberId != myId) {
            othersOweMe += perPersonAmount;
          }
        }
      } else {
        // Someone else paid for the bill
        if (bill.splitWith.contains(myId)) {
          // And I am part of the split
          iOwe += perPersonAmount;
        }
      }
    }

    return {'iOwe': iOwe, 'othersOweMe': othersOweMe};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final starter = appState.starter;

    // --- Calculate owed amounts ---
    final owedAmounts = _calculateOwedMoney(appState);
    final iOwe = owedAmounts['iOwe']!;
    final othersOweMe = owedAmounts['othersOweMe']!;
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);

    return PokeBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () {
                appState.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- 1. PROFILE SECTION (with Edit Button) ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (starter != null)
                      Image.network(starter.imageUrl, width: 80, height: 80),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Display the user's name
                              Text(appState.userName, style: theme.textTheme.headlineSmall),
                              const Spacer(),
                              // --- Edit Name Button ---
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                color: Colors.grey[600],
                                tooltip: 'Edit Name',
                                onPressed: () => showRenameDialog(
                                  context,
                                  initialName: appState.userName,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your trusted partner!',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. NEW MONEY OWED SECTION ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Money Summary', style: theme.textTheme.titleLarge),
                    const Divider(height: 24),
                    // "You Owe" Row
                    _buildMoneyRow(
                      context: context,
                      label: 'You Owe',
                      amount: iOwe,
                      color: Colors.redAccent,
                      icon: Icons.arrow_circle_up_rounded,
                    ),
                    const SizedBox(height: 16),
                    // "Others Owe You" Row
                    _buildMoneyRow(
                      context: context,
                      label: 'Others Owe You',
                      amount: othersOweMe,
                      color: Colors.green,
                      icon: Icons.arrow_circle_down_rounded,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. HOME CODE SECTION (Unchanged) ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Home Info', style: theme.textTheme.titleLarge),
                    const Divider(height: 20),
                    ListTile(
                      leading: const Icon(Icons.home_work_outlined),
                      title: Text(appState.currentHome?.name ?? 'No Home'),
                      subtitle: const Text('Home Name'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.qr_code_2),
                      title: Text(appState.currentHome?.code ?? 'N/A'),
                      subtitle: const Text('Home Code'),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: appState.currentHome == null
                            ? null
                            : () {
                          // Add copy to clipboard logic here if needed
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.exit_to_app, color: Colors.red),
                        label: const Text('Leave Home', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          appState.leaveHome();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper widget for displaying money rows ---
  Widget _buildMoneyRow({
    required BuildContext context,
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Text(label, style: theme.textTheme.titleMedium),
        const Spacer(),
        Text(
          currencyFormat.format(amount),
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
