class SecureStorageKeys {
  SecureStorageKeys._();

  static const String hiveEncryptionKey = 'hive_key';

  static const String appName = 'HashLock';
}

class HiveBoxNames {
  HiveBoxNames._();

  static const String credentialsBox = 'credentials';
  static const String notesBox = 'notes';
  static const String settingsBox = 'settings';
  static const String personalBox = 'personalEntry';
}

class CredentialsKeys {
  CredentialsKeys._();

  static const String fields = 'fields';
}

class SettingsKeys {
  SettingsKeys._();

  static const String isRegistered = 'isRegistered';
  static const String username = 'userName';
  static const String userPinHash = 'userPinHash';
  static const String userPinLength = 'userPinLength';
  static const String userAvatar = 'userAvatar';
  static const String themeMode = 'themeMode';
}
