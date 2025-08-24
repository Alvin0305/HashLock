import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quartz/models/credential_entry.dart';
import 'package:quartz/providers/credential_providers.dart';
import 'package:quartz/widgets/credential_tile.dart';

class CategoryTab extends ConsumerWidget {
  final String category;
  const CategoryTab({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(filteredCredentialsProvider(category));

    void deleteCredential(CredentialEntry credential) {
      ref.read(credentialBoxProvider).delete(credential.key);
    }

    void showDeleteConfirmationDialog(CredentialEntry credential) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text(
            "Are you sure you want to delete the credentials for ${credential.serviceName}? This action cannot be undone",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteCredential(credential);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    if (credentials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category == "Work" ? Icons.work : Icons.group,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              "No credentials in $category yet",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the + button to add your first note",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: credentials.length,
        itemBuilder: (context, index) => CredentialTile(
          credential: credentials[index],
          onDelete: () => showDeleteConfirmationDialog(credentials[index]),
        ),
      );
    }
  }
}
