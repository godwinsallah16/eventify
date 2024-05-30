class MaskMail {
  late final String _email;

  MaskMail(this._email);

  String maskEmail() {
    final parts = _email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) {
      return _email; // if the username is too short to mask, return it as is
    }

    final start = username.substring(0, 3);
    final end = username.substring(username.length - 2);

    return '$start***$end@$domain';
  }
}
