import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/providers/settings_providers.dart';
import 'package:quartz/services/app_services.dart';

enum ChangePinStep { verify, create, confirm }

class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  ChangePinStep _currentStep = ChangePinStep.verify;
  final _pinController = TextEditingController();
  String _newPin = '';

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final enteredPin = _pinController.text;
    if (enteredPin.isEmpty) return;

    final SettingsBox = ref.read(settingsBoxProvider);

    switch (_currentStep) {
      case ChangePinStep.verify:
        final storedHash = SettingsBox.get(SettingsKeys.userPinHash);
        final enteredHash = sha256.convert(utf8.encode(enteredPin)).toString();

        if (enteredHash == storedHash) {
          setState(() {
            _currentStep = ChangePinStep.create;
            _pinController.clear();
          });
        } else {
          showMessage(context, "Incorrect current PIN. Please Try Again");
          _pinController.clear();
        }
        break;
      case ChangePinStep.create:
        _newPin = enteredPin;
        setState(() {
          _currentStep = ChangePinStep.confirm;
          _pinController.clear();
        });
        break;
      case ChangePinStep.confirm:
        if (enteredPin == _newPin) {
          final newHash = sha256.convert(utf8.encode(_newPin)).toString();
          SettingsBox.put(SettingsKeys.userPinHash, newHash);

          showMessage(context, "Your PIN has been updated succesfully");
          Navigator.of(context).pop();
        } else {
          showMessage(context, "PINs do not match. Please start over.");
          setState(() {
            _currentStep = ChangePinStep.create;
            _pinController.clear();
          });
        }
        break;
    }
  }

  String _getTitle() {
    switch (_currentStep) {
      case ChangePinStep.verify:
        return 'Enter Your Current PIN';
      case ChangePinStep.create:
        return 'Enter Your New PIN';
      case ChangePinStep.confirm:
        return 'Confirm Your New PIN';
    }
  }

  String _getButtonText() {
    switch (_currentStep) {
      case ChangePinStep.verify:
        return 'Verify';
      case ChangePinStep.create:
        return 'Next';
      case ChangePinStep.confirm:
        return 'Confirm And Save';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change PIN")),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _getTitle(),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 0),
              decoration: const InputDecoration(
                labelText: "PIN",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_getButtonText()),
            ),
          ],
        ),
      ),
    );
  }
}
