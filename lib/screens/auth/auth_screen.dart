import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:quartz/providers/settings_providers.dart';
import 'package:quartz/screens/home/home_screen.dart';
import 'package:quartz/services/app_services.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _pinController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    _pinController.addListener(_handleVerify);
    _authenticateWithBiometrics();

    super.initState();
  }

  @override
  void dispose() {
    _pinController.removeListener(_handleVerify);
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: "Scan you fingerprint or face to authenticate",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
      return;
    }

    if (!mounted) return;

    if (authenticated) {
      navigatePushReplacement(context, HomeScreen());
    }
  }

  void _handleVerify() {
    final settingsBox = Hive.box(HiveBoxNames.settingsBox);
    final storedHash = settingsBox.get(SettingsKeys.userPinHash);

    String enteredPIN = _pinController.text;
    final bytes = utf8.encode(enteredPIN);
    final digest = sha256.convert(bytes);
    final hashedPin = digest.toString();

    if (hashedPin == storedHash) {
      _pinController.clear();
      navigatePushReplacement(context, HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = ref.watch(usernameProvider);
    final avatarId = ref.watch(avatarProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: ClipOval(
                  child: Image.asset(
                    'assets/avatars/$avatarId.png',
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Welcome back, $username",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your PIN to unlock",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 48),

              TextFormField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: "PIN",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 40),

              IconButton(
                onPressed: _authenticateWithBiometrics,
                icon: Icon(
                  Icons.fingerprint,
                  size: 60,
                  color: Colors.blueAccent,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
