/// Normalizes URL by adding https:// when missing. Handles platform-specific
/// formats (e.g. @username for Twitter/Instagram).
/// Use platform: null or 'website' for generic website URLs.
String toValidUrl(String? value, {String? platform}) {
  if (value == null || value.trim().isEmpty) return '';
  final v = value.trim();
  if (v.toLowerCase().startsWith('https://')) return v;
  if (v.toLowerCase().startsWith('http://')) return 'https://${v.substring(7)}';

  switch (platform) {
    case 'twitter':
      if (v.startsWith('@')) return 'https://twitter.com/${v.substring(1)}';
      if (!v.contains('.') && !v.contains('/')) return 'https://twitter.com/$v';
      break;
    case 'instagram':
      if (v.startsWith('@')) return 'https://instagram.com/${v.substring(1)}';
      if (!v.contains('.') && !v.contains('/')) return 'https://instagram.com/$v';
      break;
    case 'linkedin':
      if (v.startsWith('in/')) return 'https://linkedin.com/$v';
      if (!v.contains('.')) return 'https://linkedin.com/in/$v';
      break;
    case 'github':
      if (!v.contains('.') && !v.contains('/')) return 'https://github.com/$v';
      break;
    case 'youtube':
      if (v.startsWith('@')) return 'https://youtube.com/$v';
      if (!v.contains('.') && !v.contains('/')) return 'https://youtube.com/@$v';
      break;
    case 'facebook':
      if (!v.contains('.') && !v.contains('/')) return 'https://facebook.com/$v';
      break;
  }

  return 'https://$v';
}
