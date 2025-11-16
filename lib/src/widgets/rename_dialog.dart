// lib/src/widgets/rename_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

// A reusable dialog to rename items, in this case, the user.
void showRenameDialog(BuildContext context, {required String initialName}) {
  final nameController = TextEditingController(text: initialName);
  final appState = context.read<AppState>();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Change Your Name'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'New Trainer Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                // Call the renameUser method from AppState
                appState.renameUser(newName);
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
