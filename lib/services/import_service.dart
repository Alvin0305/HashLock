import 'package:csv/csv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/models/credential_entry.dart';
import 'package:quartz/models/entry.dart';
import 'package:quartz/models/personal_entry.dart';
import 'package:quartz/models/secure_note.dart';
import 'package:uuid/uuid.dart';

enum _CsvSection { none, credentials, notes, personal }

class ImportService {
  ImportService._();

  static Future<int> importFromCsv(String csvData) async {
    final List<List<dynamic>> rows = const CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(csvData);

    final credentialBox = Hive.box<CredentialEntry>(
      HiveBoxNames.credentialsBox,
    );
    final notesBox = Hive.box<SecureNote>(HiveBoxNames.notesBox);
    final personalBox = Hive.box<PersonalEntry>(HiveBoxNames.personalBox);
    const uuid = Uuid();

    int itemsimported = 0;

    _CsvSection currentSection = _CsvSection.none;
    Map<String, CredentialEntry> tempCredentials = {};

    for (final row in rows) {
      if (row.isEmpty ||
          row.first == null ||
          row.first.toString().trim().isEmpty) {
        continue;
      }

      String firstCell = row.first.toString();

      if (firstCell.startsWith("----")) {
        if (tempCredentials.isNotEmpty) {
          for (final cred in tempCredentials.values) {
            await credentialBox.put(cred.id, cred);
            itemsimported++;
          }
          tempCredentials.clear();
        }

        if (firstCell.contains("CREDENTIALS")) {
          currentSection = _CsvSection.credentials;
        } else if (firstCell.contains("SECURE NOTES")) {
          currentSection = _CsvSection.notes;
        } else if (firstCell.contains("PERSONAL DATA")) {
          currentSection = _CsvSection.personal;
        } else {
          currentSection = _CsvSection.none;
        }
        continue;
      }

      if (["ID", "Category", "Title", "Key"].contains(firstCell)) continue;

      try {
        switch (currentSection) {
          case _CsvSection.credentials:
            if (row.length < 5) continue;
            final id = row[0].toString();
            final category = row[1].toString();
            final serviceName = row[2].toString();
            final fieldName = row[3].toString();
            final fieldValue = row[4].toString();

            if (!tempCredentials.containsKey(id)) {
              tempCredentials[id] = CredentialEntry(
                id: id,
                serviceName: serviceName,
                category: category,
                fields: [],
              );
            }
            tempCredentials[id]!.fields.add(
              Entry(field: fieldName, value: fieldValue),
            );
            break;
          case _CsvSection.notes:
            if (row.length < 2) continue;
            final note = SecureNote(
              id: uuid.v4(),
              title: row[0].toString(),
              comment: row[1].toString(),
            );
            await notesBox.put(note.id, note);
            itemsimported++;
            break;
          case _CsvSection.personal:
            if (row.length < 2) continue;
            final entry = PersonalEntry(
              id: uuid.v4(),
              name: row[0].toString(),
              value: row[1].toString(),
            );
            await personalBox.put(entry.id, entry);
            itemsimported++;
            break;
          case _CsvSection.none:
            break;
        }
      } catch (e) {
        print("Skipping malformed row: $row. Error: $e");
      }
    }

    if (tempCredentials.isNotEmpty) {
      for (final cred in tempCredentials.values) {
        await credentialBox.put(cred.id, cred);
        itemsimported++;
      }
    }

    return itemsimported;
  }
}
