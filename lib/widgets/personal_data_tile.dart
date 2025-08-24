import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quartz/models/personal_entry.dart';
import 'package:quartz/providers/personal_entry_providers.dart';
import 'package:quartz/services/app_services.dart';

class PersonalDataTile extends ConsumerWidget {
  final PersonalEntry entry;
  const PersonalDataTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    void showEditDialog() {
      final nameController = TextEditingController();
      final valueController = TextEditingController();
      nameController.text = entry.name;
      valueController.text = entry.value;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit ${entry.name}"),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Name",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Value",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  final newEntry = PersonalEntry(
                    id: entry.id,
                    name: nameController.text,
                    value: valueController.text,
                  );

                  ref.read(personalEntryBoxProvider).put(entry.key, newEntry);

                  showMessage(context, "Personal Data Updated Succesfully");
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    void showDeleteDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete ${entry.name}"),
          content: Text(
            "Are you sure you want to delete ${entry.name}? This action cannot be undone",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(personalEntryBoxProvider).delete(entry.key);
              },
              child: Text(
                "Delete",
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    entry.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: showEditDialog,
                      tooltip: 'Edit',
                      color: theme.colorScheme.primary,
                      iconSize: 22,
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: entry.value));
                        showMessage(context, '"${entry.key}" value copied');
                      },
                      tooltip: 'Copy Value',
                      color: theme.colorScheme.primary,
                      iconSize: 22,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: showDeleteDialog,
                      tooltip: 'Delete',
                      color: theme.colorScheme.error,
                      iconSize: 22,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 12),
            SelectableText(
              entry.value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
