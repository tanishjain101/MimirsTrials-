import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF46E3B7);
  static const Color secondary = Color(0xFF4C7DFF);
  static const Color accent = Color(0xFFFFC857);
  static const Color pink = Color(0xFFFF6BCB);

  static const Color background = Color(0xFF0B0F1C);
  static const Color backgroundAlt = Color(0xFF11162A);
  static const Color surface = Color(0xFF141A2E);
  static const Color surfaceAlt = Color(0xFF1C233B);
  static const Color surfaceElevated = Color(0xFF202845);
  static const Color navBackground = Color(0xFF101524);
  static const Color navBorder = Color(0xFF283056);

  static const Color text = Color(0xFFF5F7FF);
  static const Color textLight = Color(0xFFB5BED6);
  static const Color textMuted = Color(0xFF7D8AB0);

  static const Color success = Color(0xFF4CE3A1);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFC857);
  static const Color info = Color(0xFF4C7DFF);

  static const Color gold = Color(0xFFFFD166);
  static const Color silver = Color(0xFFC4C9D4);
  static const Color bronze = Color(0xFFCD7F32);

  static const Color pathCompleted = Color(0xFF46E3B7);
  static const Color pathCurrent = Color(0xFFFFC857);
  static const Color pathLocked = Color(0xFF2A3354);
  static const Color nodeCompleted = Color(0xFF46E3B7);
  static const Color nodeCurrent = Color(0xFF4C7DFF);
  static const Color nodeLocked = Color(0xFF3A4667);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF46E3B7), Color(0xFF2FB990)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFC857), Color(0xFFFF9F43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1B254A), Color(0xFF12172C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C2542), Color(0xFF131A31)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
