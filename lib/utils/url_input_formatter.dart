import 'package:flutter/services.dart';

/// Prefix for each URL platform. User types only the part after the prefix.
String urlPrefixForPlatform(String? platform) {
  switch (platform) {
    case 'twitter':
      return 'https://twitter.com/';
    case 'instagram':
      return 'https://instagram.com/';
    case 'linkedin':
      return 'https://linkedin.com/in/';
    case 'github':
      return 'https://github.com/';
    case 'youtube':
      return 'https://youtube.com/';
    case 'facebook':
      return 'https://facebook.com/';
    default:
      return 'https://';
  }
}

/// Adds https:// (or platform URL) prefix as soon as user types.
class UrlPrefixInputFormatter extends TextInputFormatter {
  final String prefix;

  UrlPrefixInputFormatter({this.prefix = 'https://'});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    String text = newValue.text;

    if (text.toLowerCase().startsWith(prefix)) {
      return newValue;
    }
    // User deleted into the prefix - restore full prefix
    if (text.length < prefix.length &&
        prefix.toLowerCase().startsWith(text.toLowerCase())) {
      return TextEditingValue(
        text: prefix,
        selection: TextSelection.collapsed(offset: prefix.length),
      );
    }
    if (text.toLowerCase().startsWith('http://')) {
      text = 'https://${text.substring(7)}';
      final offset = (newValue.selection.end + 1).clamp(0, text.length);
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: offset),
      );
    }

    // Prepend prefix
    text = prefix + text;
    final offset = (newValue.selection.baseOffset + prefix.length)
        .clamp(0, text.length);
    final extent = (newValue.selection.extentOffset + prefix.length)
        .clamp(0, text.length);
    return TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: offset, extentOffset: extent),
    );
  }
}
