import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quartz/models/personal_entry.dart';
import 'package:quartz/providers/personal_entry_providers.dart';
import 'package:quartz/providers/search_provider.dart';
import 'package:quartz/screens/home/credentials/add_credentials_screen.dart';
import 'package:quartz/screens/home/notes/add_notes_screen.dart';
import 'package:quartz/screens/home/tabs/category_tab.dart';
import 'package:quartz/screens/home/tabs/notes_tab.dart';
import 'package:quartz/screens/home/tabs/personal_tab.dart';
import 'package:quartz/screens/profile_screen.dart';
import 'package:quartz/services/app_services.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  bool _isSearching = false;
  final _searchController = TextEditingController();

  final List<Widget> _pages = [
    PersonalTab(),
    CategoryTab(category: "Work"),
    CategoryTab(category: "Social"),
    NotesTab(),
  ];
  final List<IconData> _icons = [
    Icons.person_outline,
    Icons.work_outline,
    Icons.group_outlined,
    Icons.notes_rounded,
  ];
  final List<String> _labels = ["Personal", "Work", "Social", "Notes"];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (!_isSearching) {
      _searchController.clear();
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void showAddPersonalEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddPersonalEntryDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search vault...",
                ),
                style: theme.appBarTheme.titleTextStyle,
              )
            : Text(_labels[_currentIndex]),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          if (!_isSearching)
            IconButton(
              onPressed: () => navigatePush(context, ProfileScreen()),
              icon: Icon(Icons.settings_outlined),
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _icons.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.grey;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icons[index], size: 24, color: color),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _labels[index],
                  maxLines: 1,
                  style: TextStyle(color: color, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        activeIndex: _currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 10,
        rightCornerRadius: 10,
        onTap: (index) => onTabTapped(index),
        height: 60,
        shadow: BoxShadow(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),

          spreadRadius: 1,
          blurRadius: 10,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentCategory = _labels[_currentIndex];
          if (currentCategory == "Notes") {
            navigatePush(context, AddNotesScreen());
            return;
          } else if (currentCategory == "Personal") {
            showAddPersonalEntryDialog();
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  AddCredentialsScreen(initialCategory: currentCategory),
            ),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _AddPersonalEntryDialog extends ConsumerStatefulWidget {
  const _AddPersonalEntryDialog();
  @override
  ConsumerState<_AddPersonalEntryDialog> createState() =>
      _AddPersonalEntryDialogState();
}

class _AddPersonalEntryDialogState
    extends ConsumerState<_AddPersonalEntryDialog> {
  late final TextEditingController keyController;
  late final TextEditingController valueController;

  @override
  void initState() {
    super.initState();
    keyController = TextEditingController();
    valueController = TextEditingController();
  }

  @override
  void dispose() {
    keyController.dispose();
    valueController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final key = keyController.text;
    final value = valueController.text;

    if (key.isEmpty || value.isEmpty) {
      showMessage(context, "Both fields are required.");
      return;
    }

    final uuid = const Uuid();
    final newEntry = PersonalEntry(id: uuid.v4(), name: key, value: value);

    ref.read(personalEntryBoxProvider).put(newEntry.id, newEntry);

    showMessage(context, "Personal Data Added Successfully");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Personal Data"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: keyController,
            decoration: const InputDecoration(labelText: "Key"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: valueController,
            decoration: const InputDecoration(labelText: "Value"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _saveEntry, child: const Text("Save")),
      ],
    );
  }
}
