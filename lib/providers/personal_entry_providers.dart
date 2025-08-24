import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/models/personal_entry.dart';
import 'package:quartz/providers/search_provider.dart';

final personalEntryBoxProvider = Provider<Box<PersonalEntry>>((ref) {
  return Hive.box<PersonalEntry>(HiveBoxNames.personalBox);
});

final personalEntryStreamProvider = StreamProvider<List<PersonalEntry>>((ref) {
  final box = ref.watch(personalEntryBoxProvider);
  final controller = StreamController<List<PersonalEntry>>();

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

final filteredPersonalEntryProvider = Provider<List<PersonalEntry>>((ref) {
  final entriesAsync = ref.watch(personalEntryStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return entriesAsync.when(
    data: (entries) {
      if (searchQuery.isEmpty) return entries;

      return entries.where((entry) {
        final nameMatch = entry.name.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
        final valueMatch = entry.value.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );

        return nameMatch || valueMatch;
      }).toList();
    },
    error: (_, __) => [],
    loading: () => [],
  );
});
