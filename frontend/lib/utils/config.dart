import 'package:flutter_dotenv/flutter_dotenv.dart';

// 🔧 EDITABLE UI CONSTANTS
class UiConstants {
  static const String appName = 'Bharat Transliteration';
  static const List<String> supportedScripts = <String>[
    'Devanagari',
    'Telugu',
    'Tamil',
    'Malayalam',
    'Gurmukhi',
  ];
}

class AppConfig {
  // Reads API base from .env; supports toggling between local and ngrok.
  static String get apiBaseUrl {
    final ngrok = dotenv.env['NGROK_URL'];
    final base = dotenv.env['API_BASE_URL'];
    final useNgrok = dotenv.env['USE_NGROK'] == 'true';
    if (useNgrok && (ngrok != null && ngrok.isNotEmpty)) return ngrok;
    return base ?? 'http://localhost:8000';
  }
}
