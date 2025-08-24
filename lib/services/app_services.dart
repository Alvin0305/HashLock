import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:quartz/constants/app_constants.dart';
import 'package:quartz/models/credential_entry.dart';

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void navigatePushReplacement(BuildContext context, Widget screen) {
  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (context) => screen));
}

void navigatePush(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
}

List<CredentialEntry> getCredentialsByCategory(String categoryName) {
  final Box<CredentialEntry> credentialBox = Hive.box(
    HiveBoxNames.credentialsBox,
  );

  final allCredentials = credentialBox.values;
  final filteredCredentials = allCredentials
      .where((credential) => credential.category == categoryName)
      .toList();

  return filteredCredentials;
}
