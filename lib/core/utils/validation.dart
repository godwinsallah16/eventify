// validation.dart

bool isValidEmail(String? inputString, {bool isRequired = false}) {
  bool isInputStringValid = false;

  if (!isRequired && (inputString == null ? true : inputString.isEmpty)) {
    isInputStringValid = true;
  }

  if (inputString != null && inputString.isNotEmpty) {
    const pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final regExp = RegExp(pattern);
    isInputStringValid = regExp.hasMatch(inputString);
  }

  return isInputStringValid;
}

bool isValidPassword(String? inputString, {bool isRequired = false}) {
  bool isInputStringValid = false;

  if (!isRequired && (inputString == null ? true : inputString.isEmpty)) {
    isInputStringValid = true;
  }

  if (inputString != null && inputString.isNotEmpty) {
    const pattern =
        r'^(?=.*?[A-Z])(?=(.*[a-z]){1,})(?=(.*[\d]){1,})(?=(.*[\W]){1,})(?!.*\s).{8,}$';
    final regExp = RegExp(pattern);
    isInputStringValid = regExp.hasMatch(inputString);
  }

  return isInputStringValid;
}

bool isPasswordStrong(String password) {
  return isValidPassword(password);
}

String getPasswordStrength(String password) {
  if (password.isEmpty) {
    return 'empty'; // Password is empty
  } else if (password.length < 8) {
    return 'bad'; // Password is too short
  } else {
    // Check if the password has at least one number and either a special character or an uppercase letter
    bool hasNumber = password.contains(RegExp(r'\d'));
    bool hasSpecialOrUppercase = password.contains(RegExp(r'[\W_]')) ||
        password.contains(RegExp(r'[A-Z]'));

    if (!hasNumber || !hasSpecialOrUppercase) {
      return 'weak'; // Password is weak (missing number, special character, or uppercase letter)
    } else {
      return 'strong'; // Password is strong
    }
  }
}
