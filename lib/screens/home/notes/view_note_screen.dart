import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quartz/models/secure_note.dart';
import 'package:quartz/providers/notes_provider.dart';
import 'package:quartz/screens/home/notes/edit_note_screen.dart';
import 'package:quartz/services/app_services.dart';

class ViewNoteScreen extends ConsumerWidget {
  String noteId;
  ViewNoteScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void deleteNote(SecureNote note) {
      ref.read(notesBoxProvider).delete(note.key);
    }

    void showDeleteNote(SecureNote note) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Delete ${note.title}"),
          content: Text(
            "Are you sure you want to delete ${note.title}? This action cannot be undone",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                deleteNote(note);
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }

    final notesList = ref.watch(filteredNotesProvider);
    final note = notesList.firstWhere(
      (n) => n.id == noteId,
      orElse: () => SecureNote(id: '', title: 'Not Found', comment: ''),
    );

    if (note.title == 'Not Found') {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Note not found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () =>
                navigatePush(context, EditNoteScreen(noteId: noteId)),
            icon: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () => showDeleteNote(note),
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
            SelectableText(
              note.comment,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: 18, height: 1.5),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: note.comment));
          showMessage(context, "Note content copied to clipboard");
        },
        label: const Text("Copy Content"),
        icon: const Icon(Icons.copy_all_outlined),
      ),
    );
  }
}
