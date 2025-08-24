import 'package:hive_flutter/adapters.dart';
part 'personal_entry.g.dart';

@HiveType(typeId: 4)
class PersonalEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String value;

  PersonalEntry({required this.id, required this.name, required this.value});
}
