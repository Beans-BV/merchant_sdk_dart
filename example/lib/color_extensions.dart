import 'package:flutter/widgets.dart';

extension ColorExtensions on Color {
  String toHexString() {
    return '#${toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}
