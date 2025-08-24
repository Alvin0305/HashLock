import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quartz/models/secure_note.dart';
import 'package:quartz/providers/notes_provider.dart';
import 'package:quartz/services/app_services.dart';

class EditNoteScreen extends ConsumerStatefulWidget {
  final String noteId;
  const EditNoteScreen({super.key, required this.noteId});
  @override
  ConsumerState<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends ConsumerState<EditNoteScreen> {
  late final TextEditingController _contentController;
  late final TextEditingController _titleController;

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void editNote(SecureNote note) {
    final newNote = SecureNote(
      id: note.id,
      title: _titleController.text,
      comment: _contentController.text,
    );

    ref.read(notesBoxProvider).put(note.key, newNote);

    showMessage(context, "Note updated succesfully");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final notesList = ref.watch(filteredNotesProvider);
    final theme = Theme.of(context);

    final note = notesList.firstWhere(
      (n) => n.id == widget.noteId,
      orElse: () => SecureNote(id: '', title: 'Not Found', comment: ''),
    );

    if (note.title == 'Not Found') {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Note not found.")),
      );
    }

    if (!_controllersInitialized) {
      _contentController.text = note.comment;
      _titleController.text = note.title;
      _controllersInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () => editNote(note),
            icon: Icon(
              Icons.save_alt_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(5),
              ),
            ),
            const Divider(height: 24),
            TextField(
              controller: _contentController,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 1.5,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: "Your note...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
