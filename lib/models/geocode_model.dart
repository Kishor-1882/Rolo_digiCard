class GeocodeResult {
  final String? locality;
  final String? state;
  final String? country;
  final String formattedAddress;

  GeocodeResult({
    this.locality,
    this.state,
    this.country,
    required this.formattedAddress,
  });

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      return GeocodeResult(formattedAddress: '');
    }

    final first = results.first as Map<String, dynamic>;
    final addressComponents =
        first['address_components'] as List<dynamic>? ?? [];
    final formattedAddress =
        first['formatted_address'] as String? ?? '';

    String? locality;
    String? state;
    String? country;

    for (final comp in addressComponents) {
      final c = comp as Map<String, dynamic>;
      final types = (c['types'] as List<dynamic>?)?.cast<String>() ?? [];
      final longName = c['long_name'] as String? ?? '';

      if (types.contains('locality') || types.contains('administrative_area_level_3')) {
        locality ??= longName;
      }
      if (types.contains('administrative_area_level_1')) {
        state = longName;
      }
      if (types.contains('country')) {
        country = longName;
      }
    }

    return GeocodeResult(
      locality: locality,
      state: state,
      country: country,
      formattedAddress: formattedAddress,
    );
  }
}
