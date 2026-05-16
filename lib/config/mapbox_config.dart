class MapboxConfig {
  static const accessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  static void validate() {
    if (accessToken.isEmpty) {
      throw StateError(
        'Missing MAPBOX_ACCESS_TOKEN. Run with '
        '--dart-define=MAPBOX_ACCESS_TOKEN=your_mapbox_public_token.',
      );
    }
  }
}
