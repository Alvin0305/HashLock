import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/models/credential_entry.dart';
import 'package:quartz/providers/search_provider.dart';

final credentialBoxProvider = Provider<Box<CredentialEntry>>((ref) {
  return Hive.box<CredentialEntry>(HiveBoxNames.credentialsBox);
});

final credentialsStreamProvider = StreamProvider<List<CredentialEntry>>((ref) {
  final box = ref.watch(credentialBoxProvider);
  final controller = StreamController<List<CredentialEntry>>();

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

final filteredCredentialsProvider =
    Provider.family<List<CredentialEntry>, String>((ref, category) {
      final credentialsAsyncValue = ref.watch(credentialsStreamProvider);
      final searchQuery = ref.watch(searchQueryProvider);

      return credentialsAsyncValue.when(
        data: (credentials) {
          var filteredList = credentials
              .where((cred) => cred.category == category)
              .toList();
          if (searchQuery.isNotEmpty) {
            filteredList = filteredList.where((cred) {
              return cred.serviceName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
            }).toList();
          }

          return filteredList;
        },

        loading: () => [],
        error: (err, stack) => [],
      );
    });
