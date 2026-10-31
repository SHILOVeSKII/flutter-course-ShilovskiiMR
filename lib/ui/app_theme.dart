import 'package:flutter/material.dart';

abstract final class AppStyle {
  static const background = Color(0xFFF6F4F0);
  static const accent = Color(0xFF1F5F5B);
  static const ink = Color(0xFF202321);
  static const muted = Color(0xFF6C706D);
  static const line = Color(0xFFEAE7E1);
  static const danger = Color(0xFFE34D53);
  static const errorInk = Color(0xFFB92736);
  static final theme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      primary: accent,
      surface: Colors.white,
      onSurface: ink,
      error: errorInk,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, color: ink, height: 1.35),
      bodySmall: TextStyle(fontSize: 12, color: muted),
      titleLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accent),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
      elevation: 3,
    ),
  );

  static Widget frame(BuildContext context, Widget? child) => ColoredBox(
    color: background,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: child!,
      ),
    ),
  );
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, size: 20),
    style: IconButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: color ?? AppStyle.ink,
      side: const BorderSide(color: AppStyle.line),
      minimumSize: const Size(40, 40),
      shape: const CircleBorder(),
    ),
  );
}

class CategoryLabel extends StatelessWidget {
  final String category;
  const CategoryLabel(this.category, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFE4F0EF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          switch (category) {
            'Фантастика' => Icons.auto_awesome_outlined,
            'Антиутопия' => Icons.visibility_outlined,
            'Сказка' => Icons.public,
            'Фэнтези' => Icons.auto_fix_high,
            _ => Icons.menu_book_outlined,
          },
          size: 12,
          color: AppStyle.accent,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            category,
            style: const TextStyle(fontSize: 11, color: AppStyle.accent),
          ),
        ),
      ],
    ),
  );
}
