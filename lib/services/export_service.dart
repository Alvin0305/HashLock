import 'package:csv/csv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/models/credential_entry.dart';
import 'package:quartz/models/personal_entry.dart';
import 'package:quartz/models/secure_note.dart';

class ExportService {
  ExportService._();

  static Future<String> generateCsv() async {
    final credentialBox = Hive.box<CredentialEntry>(
      HiveBoxNames.credentialsBox,
    );
    final notesBox = Hive.box<SecureNote>(HiveBoxNames.notesBox);
    final personalBox = Hive.box<PersonalEntry>(HiveBoxNames.personalBox);

    final List<CredentialEntry> credentials = credentialBox.values.toList();
    final List<SecureNote> notes = notesBox.values.toList();
    final List<PersonalEntry> personalEntries = personalBox.values.toList();

    List<List<dynamic>> rows = [];

    if (credentials.isNotEmpty) {
      rows.add(["---- CREDENTIALS ----"]);
      rows.add(["ID", "Category", "Service Name", "Field Name", "Field Value"]);
      for (final cred in credentials) {
        for (final entry in cred.fields) {
          rows.add([
            cred.id,
            cred.category,
            cred.serviceName,
            entry.field,
            entry.value,
          ]);
        }
      }
      rows.add([]);
    }

    if (notes.isNotEmpty) {
      rows.add(["---- SECURE NOTES ----"]);
      rows.add(["Title", "Content"]);
      for (final note in notes) {
        rows.add([note.title, note.comment]);
      }
      rows.add([]);
    }

    if (personalEntries.isNotEmpty) {
      rows.add(["---- PERSONAL DATA ----"]);
      rows.add(["Key", "Value"]);
      for (final entry in personalEntries) {
        rows.add([entry.name, entry.value]);
      }
      rows.add([]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }
}
