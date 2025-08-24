import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/screens/auth/auth_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();

  final _settingsBox = Hive.box(HiveBoxNames.settingsBox);

  void _handleRegister() {
    String username = _usernameController.text;
    String pin = _pinController.text;

    if (username.isEmpty) {
      _showMessage("Username cannot be empty");
      return;
    }

    if (pin.isEmpty) {
      _showMessage("Pin cannot be empty");
      return;
    }

    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    final String hashedPin = digest.toString();

    _settingsBox.put(SettingsKeys.isRegistered, true);
    _settingsBox.put(SettingsKeys.username, username);
    _settingsBox.put(SettingsKeys.userPinHash, hashedPin);

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => AuthScreen()));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.shield_moon_outlined,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Welcome to ${SecureStorageKeys.appName}!",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Let's set up your secure vault",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 48),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Your Name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _pinController,
                    decoration: const InputDecoration(
                      labelText: "Master PIN",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) => value == null || value.length < 4
                        ? 'PIN must be at least 4 digits'
                        : null,
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text("Register and Create Vault"),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
