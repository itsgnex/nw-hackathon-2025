// lib/src/pages/tabs/mart_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models.dart';
import '../../state/app_state.dart';
import 'bill_details_page.dart';

class MartPage extends StatefulWidget {
  const MartPage({super.key});

  @override
  State<MartPage> createState() => _MartPageState();
}

class _MartPageState extends State<MartPage> {
  final Set<String> _boughtItemIds = {};

  // --- DIALOG FOR ADDING A NEW GROCERY ITEM ---
  void _showAddGroceryDialog(BuildContext context) {
    final appState = context.read<AppState>();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: Theme.of(context),
          child: AlertDialog(
            title: const Text('Add Grocery Item'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text;
                  if (name.isNotEmpty) {
                    // Add with default quantity of 1 and unit 'item'
                    appState.addToBuy(name, 1.0, 'item');
                  }
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- DIALOG FOR ADDING A NEW BILL ---
  void _showAddBillDialog(BuildContext context) {
    final appState = context.read<AppState>();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final splitWith = <String>{appState.userId};

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Theme(
              data: Theme.of(context),
              child: AlertDialog(
                title: const Text('Add a New Bill'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: 'Total Amount'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 24),
                      const Text('Split with:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      SizedBox(
                        height: 150,
                        width: double.maxFinite,
                        child: ListView(
                          shrinkWrap: true,
                          children: appState.members.map((member) {
                            return CheckboxListTile(
                              title: Text(member.name),
                              value: splitWith.contains(member.id),
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  if (value == true) {
                                    splitWith.add(member.id);
                                  } else {
                                    splitWith.remove(member.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final description = descriptionController.text;
                      final totalAmount = double.tryParse(amountController.text) ?? 0.0;
                      if (description.isNotEmpty && totalAmount > 0) {
                        appState.addBill(
                          description: description,
                          totalAmount: totalAmount,
                          splitWith: splitWith,
                        );
                      }
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Add Bill'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

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
            'PokéMart & Bills',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            // --- THEMED GROCERY LIST CARD ---
            Card(
              elevation: 4,
              color: Colors.white.withOpacity(0.95), // Slight transparency to blend
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 8),
                        Text('Shopping List', style: theme.textTheme.titleLarge),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                          tooltip: 'Add Grocery Item',
                          onPressed: () => _showAddGroceryDialog(context),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    if (appState.toBuy.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: Text('Your shopping bag is empty!')),
                      ),
                    if (appState.toBuy.isNotEmpty && _boughtItemIds.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            for (final id in _boughtItemIds) {
                              appState.removeFromBuy(id);
                            }
                            setState(() {
                              _boughtItemIds.clear();
                            });
                          },
                          child: const Text('Clear Bought'),
                        ),
                      ),
                    ...appState.toBuy.map((item) {
                      final isBought = _boughtItemIds.contains(item.id);
                      final displayQty = item.qty == 1.0 ? '1' : item.qty.toStringAsFixed(1);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          setState(() {
                            if (isBought) {
                              _boughtItemIds.remove(item.id);
                            } else {
                              _boughtItemIds.add(item.id);
                            }
                          });
                        },
                        leading: Icon(
                          isBought ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                          color: isBought ? Colors.green : theme.colorScheme.onSurface.withAlpha(153),
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            decoration: isBought ? TextDecoration.lineThrough : TextDecoration.none,
                            color: isBought ? Colors.grey : theme.colorScheme.onSurface,
                            fontStyle: isBought ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                        trailing: Text('$displayQty ${item.unit}'),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- THEMED BILLS LIST CARD ---
            Card(
              elevation: 4,
              color: Colors.white.withOpacity(0.95),
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long_outlined, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 8),
                        Text('Shared Bills', style: theme.textTheme.titleLarge),
                      ],
                    ),
                    const Divider(height: 20),
                    if (appState.bills.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: Text('No bills to display!')),
                      ),
                    ...appState.bills.map((bill) {
                      final paidByName = appState.members.firstWhere((m) => m.id == bill.paidBy, orElse: () => Member(id: '', name: 'Unknown', starter: null)).name;

                      // --- THIS IS THE KEY CHANGE ---
                      // Calculate the per-person amount
                      final numPeople = bill.splitWith.length > 0 ? bill.splitWith.length : 1;
                      final perPersonAmount = bill.totalAmount / numPeople;
                      final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);
                      // --- END OF CHANGE ---

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(bill.description),
                        subtitle: Text('Paid by $paidByName'),
                        // --- UPDATED TRAILING WIDGET ---
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currencyFormat.format(bill.totalAmount),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${currencyFormat.format(perPersonAmount)}/person',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // --- END OF UPDATE ---
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => BillDetailsPage(bill: bill)),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 90), // Extra space for the FAB
          ],
        ),

        // --- FLOATING ACTION BUTTON FOR BILLS ---
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddBillDialog(context),
          tooltip: 'Add a New Bill',
          icon: const Icon(Icons.note_add),
          label: const Text('Add Bill'),
        ),
      ),
    );
  }
}
