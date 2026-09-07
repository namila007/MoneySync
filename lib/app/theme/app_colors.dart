import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color bg = Color(0xFFF3F2F2);
  static const Color surface = Color(0xFFEAE9E9);
  static const Color text = Color(0xFF201E1D);
  static const Color accent = Color(0xFFEC3013);
  static const Color accent2 = Color(0xFFE15B47);

  static Color divider(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF201E1D).withValues(alpha: 0.30)
      : const Color(0xFF201E1D).withValues(alpha: 0.40);

  static const Color neutral100 = Color(0xFFF8F4F4);
  static const Color neutral200 = Color(0xFFEAE7E7);
  static const Color neutral300 = Color(0xFFD7D3D3);
  static const Color neutral400 = Color(0xFFBAB6B6);
  static const Color neutral500 = Color(0xFF9B9797);
  static const Color neutral600 = Color(0xFF7D7979);
  static const Color neutral700 = Color(0xFF605D5D);
  static const Color neutral800 = Color(0xFF444141);
  static const Color neutral900 = Color(0xFF2D2B2B);

  static const Color accent100 = Color(0xFFFFF2EF);
  static const Color accent200 = Color(0xFFFFE0D9);
  static const Color accent300 = Color(0xFFFFC4B8);
  static const Color accent400 = Color(0xFFFF9783);
  static const Color accent500 = Color(0xFFFF563C);
  static const Color accent600 = Color(0xFFDD2B0F);
  static const Color accent700 = Color(0xFFAE1800);
  static const Color accent800 = Color(0xFF7C1405);
  static const Color accent900 = Color(0xFF4D170E);

  static const Color success = Color(0xFF1A7A3A);
  static const Color successDark = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFB45309);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color info = Color(0xFF005A9C);
  static const Color infoDark = Color(0xFF60A5FA);

  static const Color darkBg = Color(0xFF1A1918);
  static const Color darkSurface = Color(0xFF252423);
  static const Color darkText = Color(0xFFEDEBEA);
}
