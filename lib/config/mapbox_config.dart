import 'package:flutter/foundation.dart';

class MapboxConfig {
  static const accessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  static bool get hasAccessToken => accessToken.isNotEmpty;

  static void validate() {
    if (accessToken.isEmpty) {
      debugPrint(
        'Missing MAPBOX_ACCESS_TOKEN. Run with '
        '--dart-define=MAPBOX_ACCESS_TOKEN=your_mapbox_public_token.',
      );
    }
  }
}
