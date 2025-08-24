import 'package:flutter/material.dart';
import 'package:quartz/services/password_generator_service.dart';

class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  double _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    setState(() {
      _generatedPassword = PasswordGeneratorService.generatePassword(
        includeLowercase: _includeLowercase,
        includeUppercase: _includeUppercase,
        includeNumbers: _includeNumbers,
        includeSymbols: _includeSymbols,
        length: _length.toInt(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text("Password Generator"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _generatedPassword,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _generatePassword,
                    icon: Icon(Icons.refresh_rounded),
                    tooltip: 'Generate New Password',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text("Length:"),
                Expanded(
                  child: Slider.adaptive(
                    value: _length,
                    min: 8,
                    max: 32,
                    divisions: 24,
                    label: _length.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _length = value;
                      });
                    },
                    onChangeEnd: (value) {
                      _generatePassword();
                    },
                  ),
                ),
                Text(
                  _length.toInt().toString(),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            Column(
              children: [
                CheckboxListTile(
                  title: const Text("Uppercase (A-Z)"),
                  value: _includeUppercase,
                  onChanged: (value) => setState(() {
                    _includeUppercase = value!;
                    _generatePassword();
                  }),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text("Lowercase (a-z)"),
                  value: _includeLowercase,
                  onChanged: (value) => setState(() {
                    _includeLowercase = value!;
                    _generatePassword();
                  }),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text("Numbers (0-9)"),
                  value: _includeNumbers,
                  onChanged: (value) => setState(() {
                    _includeNumbers = value!;
                    _generatePassword();
                  }),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text("Symbols (!@#)"),
                  value: _includeSymbols,
                  onChanged: (value) => setState(() {
                    _includeSymbols = value!;
                    _generatePassword();
                  }),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_generatedPassword),
          child: const Text("Use password"),
        ),
      ],
    );
  }
}
