import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local cache used to make screens feel instant.
///
/// Firebase Realtime Database streams always have to make a round trip
/// before they can show anything. By writing the last good response to
/// disk (as plain JSON) and reading it back synchronously on the next
/// launch, screens like Home can paint real content immediately instead
/// of a blank skeleton — the live listener then silently replaces it the
/// moment fresh data arrives.
class LocalCacheService {
  LocalCacheService._();

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Saves any JSON-encodable value (list/map of primitives) under [key].
  static Future<void> saveJson(String key, dynamic data) async {
    try {
      final prefs = await _instance;
      await prefs.setString(key, jsonEncode(data));
    } catch (_) {
      // Caching is a nice-to-have; never let a write failure affect the
      // live data path.
    }
  }

  /// Reads back whatever was stored under [key], or null if there's
  /// nothing cached yet (or it failed to decode).
  static Future<dynamic> readJson(String key) async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(key);

      if (raw == null || raw.isEmpty) return null;

      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> remove(String key) async {
    try {
      final prefs = await _instance;
      await prefs.remove(key);
    } catch (_) {
      // Ignore.
    }
  }
}
