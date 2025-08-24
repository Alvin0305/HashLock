import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quartz/models/credential_entry.dart';
import 'package:quartz/models/entry.dart';
import 'package:quartz/providers/credential_providers.dart';
import 'package:quartz/services/app_services.dart';

class ViewCredentialsScreen extends ConsumerStatefulWidget {
  final String credentialId;
  const ViewCredentialsScreen({super.key, required this.credentialId});

  @override
  ConsumerState<ViewCredentialsScreen> createState() =>
      _ViewCredentialsScreenState();
}

class _ViewCredentialsScreenState extends ConsumerState<ViewCredentialsScreen> {
  final Set<String> _visibleFields = {};
  String? _lastProcessedCredentialId;

  void _showAddEntry(CredentialEntry currentCredentialEntry) {
    final newFieldController = TextEditingController();
    final newValueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add to ${currentCredentialEntry.serviceName}"),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newFieldController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Field Name",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newValueController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Value",
              ),
            ),
          ],
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
              final newField = newFieldController.text;
              final newValue = newValueController.text;

              if (newField.isEmpty || newValue.isEmpty) {
                return;
              }
              final newEntry = Entry(field: newField, value: newValue);
              final updatedFields = List<Entry>.from(
                currentCredentialEntry.fields,
              )..add(newEntry);

              final updatedCredentials = CredentialEntry(
                id: currentCredentialEntry.id,
                serviceName: currentCredentialEntry.serviceName,
                category: currentCredentialEntry.category,
                fields: updatedFields,
              );

              ref
                  .read(credentialBoxProvider)
                  .put(updatedCredentials.id, updatedCredentials);

              showMessage(context, "Field Added Succesfully");

              if (!newField.toLowerCase().contains("password")) {
                _visibleFields.add(newField);
              }

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

  void _showEditEntry(CredentialEntry currentCredentialEntry, Entry entry) {
    final newValueController = TextEditingController();
    newValueController.text = entry.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${entry.field}"),
        content: TextField(
          controller: newValueController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Value",
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
              final updatedFields = List<Entry>.from(
                currentCredentialEntry.fields,
              );

              final indexToUpdate = updatedFields.indexWhere(
                (e) => e.field == entry.field,
              );

              if (indexToUpdate != -1) {
                updatedFields[indexToUpdate].value = newValue;
              }

              final updatedCredentials = CredentialEntry(
                id: currentCredentialEntry.id,
                serviceName: currentCredentialEntry.serviceName,
                category: currentCredentialEntry.category,
                fields: updatedFields,
              );

              ref
                  .read(credentialBoxProvider)
                  .put(updatedCredentials.id, updatedCredentials);

              showMessage(context, "Value updated Succesfully");

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

  void _showDeleteEntry(CredentialEntry currentCredentialEntry, Entry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete to ${entry.field}"),
        content: Text(
          "Are you sure you want to delete ${entry.field}? This action cannot be undone",
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
              final updatedFields = List<Entry>.from(
                currentCredentialEntry.fields,
              )..remove(entry);

              final updatedCredentials = CredentialEntry(
                id: currentCredentialEntry.id,
                serviceName: currentCredentialEntry.serviceName,
                category: currentCredentialEntry.category,
                fields: updatedFields,
              );

              ref
                  .read(credentialBoxProvider)
                  .put(updatedCredentials.id, updatedCredentials);

              showMessage(context, "Field Deleted Succesfully");

              Navigator.of(context).pop();
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final credentialsStream = ref.watch(credentialsStreamProvider);

    return credentialsStream.when(
      data: (credentials) {
        final credential = credentials.firstWhere(
          (c) => c.id == widget.credentialId,
          orElse: () => CredentialEntry(
            id: '',
            serviceName: 'Not Found',
            category: '',
            fields: [],
          ),
        );

        if (credential.serviceName == "Not Found") {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Credentials not found.')),
          );
        }

        if (_lastProcessedCredentialId != credential.id ||
            _lastProcessedCredentialId == null) {
          _visibleFields.clear();

          for (var entry in credential.fields) {
            if (!entry.field.toLowerCase().contains("password")) {
              _visibleFields.add(entry.field);
            }
          }

          _lastProcessedCredentialId = credential.id;
        }
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(title: Text(credential.serviceName)),
          body: ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: credential.fields.length,
            itemBuilder: (context, index) {
              final entry = credential.fields[index];
              final key = entry.field;
              final value = entry.value;
              final isPassword = key.toLowerCase().contains("password");
              final isVisible = _visibleFields.contains(key);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
                  // onDoubleTap: () => _showEditEntry(credential, entry),
                  // onLongPress: () => _showDeleteEntry(credential, entry),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              key,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPassword)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (isVisible) {
                                        _visibleFields.remove(key);
                                      } else {
                                        _visibleFields.add(key);
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    isVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              IconButton(
                                onPressed: () =>
                                    _showEditEntry(credential, entry),
                                icon: Icon(Icons.edit_outlined),
                                tooltip: 'Edit',
                                color: theme.colorScheme.primary,
                                iconSize: 22,
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: value));
                                  showMessage(
                                    context,
                                    "Copied $value to clipboard",
                                  );
                                },
                                icon: Icon(Icons.copy),
                                tooltip: 'Copy',
                                color: theme.colorScheme.primary,
                                iconSize: 22,
                              ),
                              IconButton(
                                onPressed: () =>
                                    _showDeleteEntry(credential, entry),
                                icon: Icon(Icons.delete_outline),
                                tooltip: 'Delete',
                                color: theme.colorScheme.error,
                                iconSize: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 12),
                      Text(
                        isVisible ? value : "••••••••",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  // child: ListTile(
                  //   title: Text(
                  //     key,
                  //     style: const TextStyle(fontWeight: FontWeight.bold),
                  //   ),
                  // subtitle:
                  //   trailing: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [

                  //       IconButton(
                  // onPressed: () {
                  //   Clipboard.setData(ClipboardData(text: value));
                  //   showMessage(context, "Copied $value to clipboard");
                  // },
                  //         icon: Icon(Icons.copy),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEntry(credential),
            shape: CircleBorder(),
            child: Icon(Icons.add),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error $err')),
      ),
    );
  }
}
