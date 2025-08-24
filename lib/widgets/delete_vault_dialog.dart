import 'package:flutter/material.dart';

class DeleteVaultDialog extends StatefulWidget {
  const DeleteVaultDialog({super.key});

  @override
  State<DeleteVaultDialog> createState() => _DeleteVaultDialogState();
}

class _DeleteVaultDialogState extends State<DeleteVaultDialog> {
  final _controller = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isButtonEnabled = _controller.text == "DELETE";
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text("Delete Vault?"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This is a permanent action and cannot be undone. All your saved credentials, notes, and personal data will be erased forever",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "To confirm, please type DELETE in the box below",
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "DELETE",
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isButtonEnabled
              ? () => Navigator.of(context).pop(true)
              : null),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isButtonEnabled
                ? theme.colorScheme.error
                : Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: const Text("Confirm Deletion"),
        ),
      ],
    );
  }
}
