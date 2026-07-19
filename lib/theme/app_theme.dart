import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color blue = Color(0xFF4A90E2);
  static const Color green = Color(0xFF5BC85B);
  static const Color yellow = Color(0xFFFFD54F);
  static const Color orange = Color(0xFFFF8A65);

  static const Color blueDark = Color(0xFF2F6FC4);
  static const Color greenDark = Color(0xFF3DA33D);

  static const Color bg = Color(0xFFF7FAFF);
  static const Color card = Colors.white;

  static const Color textDark = Color(0xFF2D3142);
  static const Color muted = Color(0xFF8A93A6);

  static const Color coin = Color(0xFFFFC24B);
  static const Color star = Color(0xFFFFD54F);
  static const Color heart = Color(0xFFFF6B81);
  static const Color success = Color(0xFF5BC85B);
  static const Color error = Color(0xFFFF6B6B);

  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 23, 108, 213),
      Color.fromARGB(255, 59, 164, 229),
      Color.fromARGB(255, 170, 201, 255)
    ],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, Color(0xFFFF6F91)],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [blue, blueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [green, greenDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navBarGradient = LinearGradient(
    colors: [blueDark, blue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient contentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEAF2FF), Color(0xFFF3EFFF), Color(0xFFFFF6EC)],
  );
}

class AppRadius {
  AppRadius._();
  static const double sm = 14;
  static const double md = 20;
  static const double lg = 28;
  static const double pill = 100;
}

class AppShadows {
  AppShadows._();
  static List<BoxShadow> soft = [
    BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 18,
        offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> colored(Color color) => [
        BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8)),
      ];
}

class AppText {
  AppText._();
  static final TextStyle _base = GoogleFonts.baloo2();

  static TextStyle display = _base.copyWith(
      fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static TextStyle h1 = _base.copyWith(
      fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static TextStyle h2 = _base.copyWith(
      fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static TextStyle body = _base.copyWith(
      fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textDark);
  static TextStyle bodyMuted = _base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: const Color.fromARGB(255, 251, 251, 251));
  static TextStyle button = _base.copyWith(
      fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white);
}

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
      primary: AppColors.blue,
      secondary: AppColors.green,
      tertiary: AppColors.orange,
    ),
    textTheme: GoogleFonts.baloo2TextTheme(),
    fontFamily: GoogleFonts.baloo2().fontFamily,
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent),
  );
}
