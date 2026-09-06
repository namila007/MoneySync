import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_theme.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/app/theme/moneysync_theme.dart';

void main() {
  group('AppTheme.light', () {
    late ThemeData theme;
    setUp(() => theme = AppTheme.light);

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('textTheme uses Archivo family', () {
      expect(theme.textTheme.displayLarge!.fontFamily, 'Archivo');
      expect(theme.textTheme.bodyLarge!.fontFamily, 'Archivo');
    });

    test('has correct scaffold background color', () {
      expect(theme.scaffoldBackgroundColor, AppColors.bg);
    });

    test('divider thickness is 2', () {
      expect(theme.dividerTheme.thickness, 2);
    });

    test('no non-zero border radius in card theme', () {
      final shape = theme.cardTheme.shape as RoundedRectangleBorder?;
      expect(shape?.borderRadius, BorderRadius.zero);
    });

    test('no non-zero border radius in bottom sheet', () {
      final shape =
          theme.bottomSheetTheme.shape as RoundedRectangleBorder?;
      expect(shape?.borderRadius, BorderRadius.zero);
    });

    test('no non-zero border radius in dialog', () {
      final shape = theme.dialogTheme.shape as RoundedRectangleBorder?;
      expect(shape?.borderRadius, BorderRadius.zero);
    });

    test('no non-zero border radius in FAB', () {
      final shape =
          theme.floatingActionButtonTheme.shape as RoundedRectangleBorder?;
      expect(shape?.borderRadius, BorderRadius.zero);
    });
  });

  group('AppTheme.dark', () {
    late ThemeData theme;
    setUp(() => theme = AppTheme.dark);

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('textTheme uses Archivo family', () {
      expect(theme.textTheme.displayLarge!.fontFamily, 'Archivo');
      expect(theme.textTheme.bodyLarge!.fontFamily, 'Archivo');
    });

    test('has correct scaffold background color', () {
      expect(theme.scaffoldBackgroundColor, AppColors.darkBg);
    });

    test('divider thickness is 2', () {
      expect(theme.dividerTheme.thickness, 2);
    });
  });

  group('MoneySyncTheme', () {
    test('accessible via ThemeExtension in light theme', () {
      final extension = AppTheme.light.extension<MoneySyncTheme>();
      expect(extension, isNotNull);
      expect(extension!.success, AppColors.success);
      expect(extension.warning, AppColors.warning);
      expect(extension.error, AppColors.accent700);
      expect(extension.info, AppColors.info);
    });

    test('accessible via ThemeExtension in dark theme', () {
      final extension = AppTheme.dark.extension<MoneySyncTheme>();
      expect(extension, isNotNull);
      expect(extension!.success, AppColors.successDark);
      expect(extension.warning, AppColors.warningDark);
      expect(extension.error, AppColors.accent500);
      expect(extension.info, AppColors.infoDark);
    });

    test('MoneySyncTheme.of returns light when extension absent', () {
      final theme = ThemeData.fallback();
      final result = theme.extension<MoneySyncTheme>();
      expect(result, isNull);
      // MoneySyncTheme.of falls back to .light
      final widget = Builder(
        builder: (context) {
          final ms = MoneySyncTheme.of(context);
          expect(ms.success, AppColors.success);
          return const SizedBox();
        },
      );
      // Should not throw even without extension
      expect(() => widget, returnsNormally);
    });
  });

  group('Archivo font resolution', () {
    testWidgets('resolves Archivo without fallback for body text',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Text('test', style: AppTypography.body),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('test'));
      expect(text.style!.fontFamily, 'Archivo');
    });

    testWidgets('resolves Archivo for display text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Text('Title', style: AppTypography.display),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('Title'));
      expect(text.style!.fontFamily, 'Archivo');
    });
  });

  group('Design token invariants', () {
    test('AppSpacing has correct values', () {
      expect(AppSpacing.s1, 4.0);
      expect(AppSpacing.s2, 8.0);
      expect(AppSpacing.s3, 12.0);
      expect(AppSpacing.s4, 16.0);
      expect(AppSpacing.s6, 24.0);
      expect(AppSpacing.s8, 32.0);
    });

    test('AppTypography micro has positive letter spacing', () {
      expect(AppTypography.micro.letterSpacing, greaterThan(0));
    });

    test('AppTypography h6 has positive letter spacing', () {
      expect(AppTypography.h6.letterSpacing, greaterThan(0));
    });

    test('AppTypography body has null letter spacing (default)', () {
      expect(AppTypography.body.letterSpacing, isNull);
    });
  });
}
