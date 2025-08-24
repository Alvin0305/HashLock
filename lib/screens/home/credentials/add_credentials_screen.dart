import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quartz/models/credential_entry.dart';
import 'package:quartz/models/entry.dart';
import 'package:quartz/services/app_services.dart';
import 'package:quartz/providers/credential_providers.dart';
import 'package:quartz/widgets/password_generator_dialog.dart';
import 'package:uuid/uuid.dart';

class AddCredentialsScreen extends ConsumerStatefulWidget {
  final String initialCategory;
  const AddCredentialsScreen({super.key, required this.initialCategory});

  @override
  ConsumerState<AddCredentialsScreen> createState() =>
      _AddCredentialsScreenState();
}

class _AddCredentialsScreenState extends ConsumerState<AddCredentialsScreen> {
  final _serviceNameController = TextEditingController();

  final List<Map<String, TextEditingController>> _fieldControllers = [];

  void _saveCredential() {
    final serviceName = _serviceNameController.text;
    if (serviceName.isEmpty) {
      showMessage(context, "Service name should not be empty");
      return;
    }

    List<Entry> fields = _fieldControllers
        .map(
          (controllerMap) => Entry(
            field: controllerMap['key']!.text,
            value: controllerMap['value']!.text,
          ),
        )
        .toList();

    final credentialsBox = ref.read(credentialBoxProvider);

    const uuid = Uuid();
    final newId = uuid.v4();
    final newCredential = CredentialEntry(
      id: newId,
      serviceName: serviceName,
      category: widget.initialCategory,
      fields: fields,
    );
    credentialsBox.put(newId, newCredential);

    showMessage(context, "Saved $serviceName credentials");

    Navigator.of(context).pop(true);
  }

  @override
  void initState() {
    super.initState();
    _addNewField(key: 'Username', value: '');
    _addNewField(key: 'Password', value: '');
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    for (var controllerMap in _fieldControllers) {
      controllerMap['key']!.dispose();
      controllerMap['value']!.dispose();
    }
    super.dispose();
  }

  void _addNewField({String key = '', String value = ''}) {
    setState(() {
      _fieldControllers.add({
        'key': TextEditingController(text: key),
        'value': TextEditingController(text: value),
      });
    });
  }

  void _removeField(int index) {
    setState(() {
      _fieldControllers[index]['key']!.dispose();
      _fieldControllers[index]['value']!.dispose();
      _fieldControllers.removeAt(index);
    });
  }

  void _showPasswordGeneratorDialog(TextEditingController controller) async {
    final generatedPassword = await showDialog<String>(
      context: context,
      builder: (context) => const PasswordGeneratorDialog(),
    );

    if (generatedPassword != null && generatedPassword.isNotEmpty) {
      controller.text = generatedPassword;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add to ${widget.initialCategory}"),
        actions: [
          IconButton(
            onPressed: _saveCredential,
            icon: Icon(Icons.save_alt_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _serviceNameController,
              decoration: const InputDecoration(
                labelText: "Service Name (eg. Google, Amazon)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Fields",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _fieldControllers.length,
              itemBuilder: (context, index) => _buildFieldRow(index),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _addNewField,
              icon: const Icon(Icons.add),
              label: const Text("Add another field"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow(int index) {
    final keyController = _fieldControllers[index]['key']!;
    final valueController = _fieldControllers[index]['value']!;
    final isPassword = keyController.text.toLowerCase().contains('password');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: keyController,
              decoration: const InputDecoration(labelText: "Field Name"),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: valueController,
              decoration: InputDecoration(
                labelText: "Value",
                suffixIcon: isPassword
                    ? IconButton(
                        onPressed: () =>
                            _showPasswordGeneratorDialog(valueController),
                        icon: Icon(Icons.casino_outlined),
                      )
                    : null,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
          ),
          IconButton(
            onPressed: () => _removeField(index),
            icon: Icon(
              Icons.remove_circle_outline,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
