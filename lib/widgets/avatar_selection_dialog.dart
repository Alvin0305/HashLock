import 'package:flutter/material.dart';

class AvatarSelectionDialog extends StatefulWidget {
  final String currentAvatarId;
  const AvatarSelectionDialog({super.key, required this.currentAvatarId});

  @override
  State<AvatarSelectionDialog> createState() => _AvatarSelectionDialogState();
}

class _AvatarSelectionDialogState extends State<AvatarSelectionDialog> {
  final List<String> _avatarIds = [
    "avatar_1",
    "avatar_2",
    "avatar_3",
    "avatar_4",
    "avatar_5",
    "avatar_6",
    "avatar_7",
  ];

  late String _selectedAvatarId;

  @override
  void initState() {
    super.initState();
    _selectedAvatarId = widget.currentAvatarId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Choose your avatar"),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: _avatarIds.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final avatarId = _avatarIds[index];
            final isSelected = avatarId == _selectedAvatarId;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatarId = avatarId;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        )
                      : null,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/avatars/$avatarId.png'),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedAvatarId),
          child: const Text("Select"),
        ),
      ],
    );
  }
}
