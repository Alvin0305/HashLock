import 'package:hive_flutter/adapters.dart';
import 'package:quartz/models/entry.dart';

part 'credential_entry.g.dart';

@HiveType(typeId: 1)
class CredentialEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String serviceName;

  @HiveField(2)
  late String category;

  @HiveField(3)
  late List<Entry> fields;

  CredentialEntry({
    required this.id,
    required this.serviceName, 
    required this.category,
    required this.fields
  });
}