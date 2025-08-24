import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/models/credential_entry.dart';
import 'package:quartz/models/entry.dart';
import 'package:quartz/models/personal_entry.dart';
import 'package:quartz/models/secure_note.dart';
import 'package:quartz/providers/settings_providers.dart';
import 'package:quartz/screens/auth/auth_screen.dart';
import 'package:quartz/screens/auth/register_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quartz/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const secureStorage = FlutterSecureStorage();
  final encryptionKeyString = await secureStorage.read(
    key: SecureStorageKeys.hiveEncryptionKey,
  );

  if (encryptionKeyString == null) {
    final key = Hive.generateSecureKey();

    await secureStorage.write(
      key: SecureStorageKeys.hiveEncryptionKey,
      value: base64UrlEncode(key),
    );
  }

  final key = base64Url.decode(
    (await secureStorage.read(key: SecureStorageKeys.hiveEncryptionKey))!,
  );

  await Hive.initFlutter();

  Hive.registerAdapter(EntryAdapter());
  Hive.registerAdapter(CredentialEntryAdapter());
  Hive.registerAdapter(SecureNoteAdapter());
  Hive.registerAdapter(PersonalEntryAdapter());

  await Hive.openBox<CredentialEntry>(
    HiveBoxNames.credentialsBox,
    encryptionCipher: HiveAesCipher(key),
  );
  await Hive.openBox<SecureNote>(
    HiveBoxNames.notesBox,
    encryptionCipher: HiveAesCipher(key),
  );
  await Hive.openBox<PersonalEntry>(
    HiveBoxNames.personalBox,
    encryptionCipher: HiveAesCipher(key),
  );
  await Hive.openBox(HiveBoxNames.settingsBox);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: SecureStorageKeys.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box(HiveBoxNames.settingsBox);
    final isRegistered = settingsBox.get(
      SettingsKeys.isRegistered,
      defaultValue: false,
    );

    if (isRegistered) {
      return AuthScreen();
    } else {
      return RegisterScreen();
    }
  }
}
