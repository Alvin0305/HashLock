import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/models/credential_entry.dart';
import 'package:quartz/models/personal_entry.dart';
import 'package:quartz/models/secure_note.dart';
import 'package:quartz/providers/settings_providers.dart';
import 'package:quartz/screens/auth/register_screen.dart';
import 'package:quartz/screens/change_pin_screen.dart';
import 'package:quartz/services/app_services.dart';
import 'package:quartz/services/export_service.dart';
import 'package:quartz/services/import_service.dart';
import 'package:quartz/widgets/avatar_selection_dialog.dart';
import 'package:quartz/widgets/delete_vault_dialog.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);
    final avatarId = ref.watch(avatarProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    void changeAvatar() async {
      final newAvatarId = await showDialog<String>(
        context: context,
        builder: (context) => AvatarSelectionDialog(currentAvatarId: avatarId),
      );

      if (newAvatarId != null) {
        ref.read(avatarProvider.notifier).state = newAvatarId;
        ref.read(settingsBoxProvider).put(SettingsKeys.userAvatar, newAvatarId);
      }
    }

    void changeUsername() {
      final usernameController = TextEditingController();
      usernameController.text = username;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Change Usernme"),
          content: TextField(
            controller: usernameController,
            autofocus: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "New Username",
            ),
            onSubmitted: (_) {
              final newName = usernameController.text;
              if (newName.isEmpty) {
                return;
              }

              ref.read(usernameProvider.notifier).state = newName;
              ref.read(settingsBoxProvider).put(SettingsKeys.username, newName);

              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = usernameController.text;
                if (newName.isEmpty) {
                  return;
                }

                ref.read(usernameProvider.notifier).state = newName;
                ref
                    .read(settingsBoxProvider)
                    .put(SettingsKeys.username, newName);

                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        ),
      );
    }

    void changePin() {
      navigatePush(context, ChangePinScreen());
    }

    void handleDeleteVault() async {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => DeleteVaultDialog(),
      );

      if (confirmed == true) {
        try {
          await Hive.box(HiveBoxNames.settingsBox).clear();
          await Hive.box<CredentialEntry>(HiveBoxNames.credentialsBox).clear();
          await Hive.box<SecureNote>(HiveBoxNames.notesBox).clear();
          await Hive.box<PersonalEntry>(HiveBoxNames.personalBox).clear();

          const secureStorage = FlutterSecureStorage();
          await secureStorage.delete(key: SecureStorageKeys.hiveEncryptionKey);

          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
              (Route<dynamic> route) => false,
            );
          }
        } catch (e) {
          if (context.mounted) {
            showMessage(context, "Error deleting vault $e");
          }
        }
      }
    }

    void performExport() async {
      try {
        showMessage(context, "Generating export file...");
        final String csvData = await ExportService.generateCsv();

        final Directory tempDir = await getTemporaryDirectory();
        final String fileName =
            'quartz_export_${DateTime.now().toIso8601String()}.csv';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsString(csvData);

        final result = await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Quartz Vault Export',
          text:
              'Here is your exported vault data. Please keep this file secure.',
        );

        if (result.status == ShareResultStatus.success) {
          if (context.mounted) {
            showMessage(context, "Export shared succesfully");
          }
        }
      } catch (e) {
        if (context.mounted) {
          showMessage(context, "An error occured during export: $e");
        }
      } finally {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      }
    }

    void handleExportVault() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ Security Warning'),
          content: const Text(
            'You are about to export your entire vault into a plain, unencrypted text file (CSV).\n\nAnyone with access to this file will be able to read all your passwords.\n\nPlease store it in a secure location and delete it when it is no longer needed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                performExport();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text("I understand, Export"),
            ),
          ],
        ),
      );
    }

    void performImport() async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );

        if (result != null && result.files.single.path != null) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Importing data...')));
          }

          final File file = File(result.files.single.path!);
          final String csvData = await file.readAsString();

          final int itemsImported = await ImportService.importFromCsv(csvData);

          if (context.mounted) {
            showMessage(context, "Succesfully import $itemsImported items");
          }
        } else {
          if (context.mounted) {
            showMessage(context, "Import cancelled");
          }
        }
      } catch (e) {
        if (context.mounted) {
          showMessage(context, "An error occured during import $e");
        }
      } finally {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      }
    }

    void handleImportVault() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Import Vault"),
          content: const Text(
            "This will add all entries from a previously exported CSV file to your vault.\n\nPlease only import files that you have created and trust.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                performImport();
              },
              child: const Text("Choose File"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile & Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: changeAvatar,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        'assets/avatars/$avatarId.png',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(username, style: theme.textTheme.headlineSmall),
                      IconButton(
                        onPressed: changeUsername,
                        icon: const Icon(Icons.edit_outlined, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Security',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Change Master PIN'),
              onTap: changePin,
            ),
            Text(
              "Appearance",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const <ButtonSegment<ThemeMode>>[
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_system_daydream_outlined),
                  label: Text('System'),
                ),
              ],
              selected: <ThemeMode>{currentThemeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(newSelection.first);
              },
              style: SegmentedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data Management',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text("Export Vault"),
              onTap: handleExportVault,
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text("Import Vault"),
              onTap: handleImportVault,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Delete Vault',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: handleDeleteVault,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
