import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quartz/models/credential_entry.dart';
import 'package:quartz/providers/credential_providers.dart';
import 'package:quartz/screens/home/credentials/view_credentials_screen.dart';
import 'package:quartz/services/app_services.dart';

class CredentialTile extends ConsumerWidget {
  final CredentialEntry credential;
  final VoidCallback onDelete;
  const CredentialTile({
    super.key,
    required this.credential,
    required this.onDelete,
  });

  IconData _getIconForServiceName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('google')) return FontAwesomeIcons.google;
    if (lowerName.contains('facebook')) return FontAwesomeIcons.facebook;
    if (lowerName.contains('twitter') || lowerName.contains('x.com')) {
      return FontAwesomeIcons.twitter;
    }
    if (lowerName.contains('instagram')) return FontAwesomeIcons.instagram;
    if (lowerName.contains('github')) return FontAwesomeIcons.github;
    if (lowerName.contains('linkedin')) return FontAwesomeIcons.linkedin;
    if (lowerName.contains('amazon')) return FontAwesomeIcons.amazon;
    if (lowerName.contains('paypal')) return FontAwesomeIcons.paypal;

    return Icons.vpn_key;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void _showEditEntry(CredentialEntry currentCredentialEntry) {
      final newValueController = TextEditingController();
      newValueController.text = currentCredentialEntry.serviceName;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Edit ${currentCredentialEntry.serviceName}"),
          content: TextField(
            controller: newValueController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Service Name",
            ),
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
                final newValue = newValueController.text;

                if (newValue.isEmpty) {
                  return;
                }

                final updatedCredentials = CredentialEntry(
                  id: currentCredentialEntry.id,
                  serviceName: newValue,
                  category: currentCredentialEntry.category,
                  fields: currentCredentialEntry.fields,
                );

                ref
                    .read(credentialBoxProvider)
                    .put(updatedCredentials.id, updatedCredentials);

                showMessage(context, "Service Name updated Succesfully");

                Navigator.of(context).pop();
              },
              child: Text(
                "Save",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: FaIcon(
          _getIconForServiceName(credential.serviceName),
          size: 32,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          credential.serviceName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(credential.fields.first.value),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
                size: 28,
              ),
            ),
            IconButton(
              onPressed: () => _showEditEntry(credential),
              icon: Icon(
                Icons.edit_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
          ],
        ),
        onTap: () => navigatePush(
          context,
          ViewCredentialsScreen(credentialId: credential.id),
        ),
      ),
    );
  }
}
