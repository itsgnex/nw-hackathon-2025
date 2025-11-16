// lib/src/pages/tabs/main_profile_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models.dart';
import '../../state/app_state.dart';
import '../../widgets/rename_dialog.dart'; // Make sure this import is correct

class MainProfilePage extends StatelessWidget {
  const MainProfilePage({super.key});

  // --- Function to calculate money owed ---
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

    // This Container provides the exact same gradient as your other pages
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF81C784), // A light, grassy green
            Color(0xFF4DB6AC), // A soft teal
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold transparent to see the gradient
        appBar: AppBar(
          title: Text(
            'Your Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
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
              elevation: 4,
              color: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (starter != null)
                      Image.network(starter.imageUrl, width: 80, height: 80)
                    else
                      const Icon(Icons.help_outline, size: 80, color: Colors.grey),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Display the user's name
                              Expanded(child: Text(appState.userName, style: theme.textTheme.headlineSmall, overflow: TextOverflow.ellipsis)),
                              // --- Edit Name Button ---
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
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
              elevation: 4,
              color: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Money Summary', style: theme.textTheme.titleLarge),
                    const Divider(height: 24),
                    _buildMoneyRow(
                      context: context,
                      label: 'You Owe',
                      amount: iOwe,
                      color: Colors.redAccent,
                      icon: Icons.arrow_circle_up_rounded,
                    ),
                    const SizedBox(height: 16),
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

            // --- 3. HOME CODE SECTION ---
            Card(
              elevation: 4,
              color: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        onPressed: appState.currentHome == null ? null : () { /* Add copy logic */ },
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

