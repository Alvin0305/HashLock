import 'package:hive_flutter/adapters.dart';

part 'secure_note.g.dart';

@HiveType(typeId: 2)
class SecureNote extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String comment;

  SecureNote({required this.id, required this.title, required this.comment});
}
