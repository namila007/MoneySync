import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String _family = 'Archivo';

  static const TextStyle display = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w800,
    fontSize: 42,
    letterSpacing: -0.63,
    height: 1.12,
  );

  static const TextStyle h1 = display;

  static const TextStyle h2 = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w800,
    fontSize: 32,
    letterSpacing: -0.48,
    height: 1.12,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w800,
    fontSize: 25,
    letterSpacing: -0.375,
    height: 1.12,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w800,
    fontSize: 20,
    letterSpacing: -0.3,
    height: 1.12,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w800,
    fontSize: 16,
    letterSpacing: -0.24,
    height: 1.12,
  );

  static const TextStyle h6 = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w800,
    fontSize: 13,
    letterSpacing: 1.04,
    height: 1.12,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.55,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.55,
  );

  static const TextStyle bodyXs = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.55,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w800,
    fontSize: 14,
    height: 1.2,
  );

  static const TextStyle micro = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w400,
    fontSize: 11,
    letterSpacing: 0.77,
    height: 1.4,
  );

  static const TextStyle amount = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w800,
    fontSize: 26,
    letterSpacing: -0.39,
    height: 1.12,
  );

  static const TextStyle count = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w800,
    fontSize: 20,
    letterSpacing: -0.3,
    height: 1.12,
  );

  static TextTheme get textTheme => const TextTheme(
    displayLarge: display,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: h4,
    titleMedium: h5,
    titleSmall: h6,
    bodyLarge: body,
    bodyMedium: bodySmall,
    bodySmall: bodyXs,
    labelLarge: label,
    labelSmall: micro,
  );
}
