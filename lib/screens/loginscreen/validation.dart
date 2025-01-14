import 'package:flutter/services.dart';

String? validateEmailAddress(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email address is required';
  }

  String emailRegex = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
  RegExp regex = RegExp(emailRegex);

  if (!regex.hasMatch(value)) {
    return 'Enter a valid email address';
  }

  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Username is required';
  }
  String usernameRegex = r'^[a-zA-Z0-9_]{3,20}$';
  RegExp regex = RegExp(usernameRegex);

  if (!regex.hasMatch(value)) {
    return 'Enter a valid username';
  }

  return null;
}

class EmojiFilteringFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filteredValue =
        newValue.text.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
    return newValue.copyWith(text: filteredValue);
  }
}
