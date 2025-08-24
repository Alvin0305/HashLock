import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quartz/models/secure_note.dart';
import 'package:quartz/providers/notes_provider.dart';
import 'package:quartz/screens/home/notes/view_note_screen.dart';
import 'package:quartz/services/app_services.dart';

class NotesTab extends ConsumerWidget {
  const NotesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesList = ref.watch(filteredNotesProvider);

    void deleteNote(SecureNote note) {
      ref.read(notesBoxProvider).delete(note.key);
    }

    void showDeleteNote(SecureNote note) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete ${note.title}"),
          content: Text(
            "Are you sure you want to delete ${note.title}? This action cannot be undone",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
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

    if (notesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notes_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              "No secure notes yet",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the + button to add your first note",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: notesList.length,
      itemBuilder: (context, index) {
        final note = notesList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: ListTile(
            onTap: () => navigatePush(context, ViewNoteScreen(noteId: note.id)),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                note.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            subtitle: Text(
              note.comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            trailing: IconButton(
              onPressed: () => showDeleteNote(note),
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      },
    );
  }
}
