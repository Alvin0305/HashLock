import 'package:hive_flutter/hive_flutter.dart';
part 'entry.g.dart';

@HiveType(typeId: 3)
class Entry extends HiveObject {
  @HiveField(0)
  late String field;

  @HiveField(1)
  late String value;

  Entry({required this.field, required this.value});
}
