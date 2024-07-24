import 'package:flutter/widgets.dart';

extension ColorExtensions on Color {
  String toHexString() {
    final valueOne = '#${value.toRadixString(16).substring(2).toUpperCase()}';
    return valueOne;
  }
}
