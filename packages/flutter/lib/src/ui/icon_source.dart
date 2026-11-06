// Derived from FlClash lib/common/string.dart:76-99, commit
// be84736605527034689c95bf27828ff27d912c5e; GPL-3.0.
// Modified 2026-11-05: top-level helpers and debugPrint; no app log provider.
import 'dart:convert';
import 'package:flutter/foundation.dart';

Uint8List? decodeIconData(String source) {
  final match = RegExp(r'base64,(.*)').firstMatch(source);
  final value = match?.group(1) ?? '';
  if (value.isEmpty) return null;
  try {
    return base64.decode(value);
  } catch (error) {
    debugPrint('invalid base64 data $error');
    return null;
  }
}

bool isSvgSource(String source) {
  if (source.startsWith('data:')) return source.startsWith('data:image/svg+xml');
  return (Uri.tryParse(source)?.path ?? source).toLowerCase().endsWith('.svg');
}
