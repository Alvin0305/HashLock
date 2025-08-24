import 'dart:math';
import 'dart:core';

class PasswordGeneratorService {
  PasswordGeneratorService._();

  static String generatePassword({
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
    int length = 16,
  }) {
    const String uppercaseChars = "ABCDEFGHIJLMNOPQRSTUVWXYZ";
    const String lowercaseChars = "abcdefghijklmnopqrstuvwxyz";
    const String numberChars = "0123456789";
    const String symbolChars = "!@#\$%^&*()_+-=[]{}|;:,.<>?";

    String allowedChars = '';
    if (includeUppercase) allowedChars += uppercaseChars;
    if (includeLowercase) allowedChars += lowercaseChars;
    if (includeNumbers) allowedChars += numberChars;
    if (includeSymbols) allowedChars += symbolChars;

    if (allowedChars.isEmpty) {
      return "Error";
    }

    final random = Random.secure();

    return List.generate(length, (index) {
      final randomIndex = random.nextInt(allowedChars.length);
      return allowedChars[randomIndex];
    }).join();
  }
}
