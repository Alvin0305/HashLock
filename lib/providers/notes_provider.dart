import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/models/secure_note.dart';
import 'package:quartz/providers/search_provider.dart';

final notesBoxProvider = Provider<Box<SecureNote>>((ref) {
  return Hive.box<SecureNote>(HiveBoxNames.notesBox);
});

final notesStreamProvider = StreamProvider<List<SecureNote>>((ref) {
  final box = ref.watch(notesBoxProvider);
  final controller = StreamController<List<SecureNote>>();

  void listener() {
    if (!controller.isClosed) {
      controller.add(box.values.toList());
    }
  }

  box.listenable().addListener(listener);
  listener();

  ref.onDispose(() {
    box.listenable().removeListener(listener);
    controller.close();
  });

  return controller.stream;
});

final filteredNotesProvider = Provider<List<SecureNote>>((ref) {
  final notesAsync = ref.watch(notesStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return notesAsync.when(
    data: (notes) {
      if (searchQuery.isEmpty) return notes;

      return notes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
        final contentMatch = note.comment.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
        return titleMatch || contentMatch;
      }).toList();
    },
    error: (err, stack) => [],
    loading: () => [],
  );
});
