import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quartz/providers/personal_entry_providers.dart';
import 'package:quartz/widgets/personal_data_tile.dart';

class PersonalTab extends ConsumerStatefulWidget {
  const PersonalTab({super.key});

  @override
  ConsumerState<PersonalTab> createState() => _PersonalTabState();
}

class _PersonalTabState extends ConsumerState<PersonalTab> {
  @override
  Widget build(BuildContext context) {
    final personalEntries = ref.watch(filteredPersonalEntryProvider);
    if (personalEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              "No personal data yet",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the + button to add your first item",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: personalEntries.length,
      itemBuilder: (context, index) =>
          PersonalDataTile(entry: personalEntries[index]),
    );
  }
}
