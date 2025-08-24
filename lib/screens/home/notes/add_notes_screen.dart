import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/models/secure_note.dart';
import 'package:quartz/services/app_services.dart';
import 'package:uuid/uuid.dart';

class AddNotesScreen extends StatefulWidget {
  const AddNotesScreen({super.key});

  @override
  State<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    String title = _titleController.text;
    final content = _contentController.text;

    final notesBox = Hive.box<SecureNote>(HiveBoxNames.notesBox);

    if (title.isEmpty) {
      title = "Title-${notesBox.length}";
    }

    if (content.isEmpty) {
      return;
    }

    final uuid = Uuid();
    final uuidId = uuid.v4();

    final note = SecureNote(id: uuidId, title: title, comment: content);
    notesBox.put(uuidId, note);

    showMessage(context, "Note saved succesfully");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Title",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Content",
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentGeometry.centerRight,
              child: ElevatedButton.icon(
                label: const Text("Save"),
                onPressed: _saveNote,
                icon: Icon(Icons.save_alt_rounded),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
