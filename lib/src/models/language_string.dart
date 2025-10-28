import 'dart:convert';

import 'package:collection/collection.dart';

/// A specialized map for handling multi-language strings.
///
/// This class extends DelegatingMap<String, String> to provide type safety and convenience methods
/// for working with localized content where keys are language codes (e.g., 'en', 'vn')
/// and values are the translated strings.
class LanguageString extends DelegatingMap<String, String> {
  /// Creates an empty LanguageString with required 'en' language.
  LanguageString() : super({'en': ''});

  /// Creates a LanguageString from an existing map.
  LanguageString.from(Map<String, String> base) : super(base) {
    if (!base.containsKey('en')) {
      throw ArgumentError('English language (en) is required');
    }
  }

  /// Creates a LanguageString from a JSON map.
  factory LanguageString.fromJson(Map<String, dynamic> json) {
    final map = json.map((key, value) {
      if (value is! String) {
        throw ArgumentError(
            'All values must be strings, got ${value.runtimeType} for key "$key"');
      }
      return MapEntry(key, value);
    });

    if (!map.containsKey('en')) {
      throw ArgumentError('English language (en) is required');
    }

    return LanguageString.from(map);
  }

  /// Creates a LanguageString from a JSON string.
  factory LanguageString.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return LanguageString.fromJson(json);
  }

  /// Converts the LanguageString to a JSON map.
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(this);
}
