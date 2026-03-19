import 'package:flutter/material.dart';

class TeacherColors {
  static const Color primary = Color(0xFF7D5CFF);
  static const Color accent = Color(0xFF4DE8C1);
  static const Color warning = Color(0xFFFFC857);
  static const Color info = Color(0xFF4C7DFF);
  static const Color background = Color(0xFF0D0B1F);
  static const Color surface = Color(0xFF1C1A3A);
  static const Color surfaceAlt = Color(0xFF24234A);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF2A1E6F), Color(0xFF15113A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AdminColors {
  static const Color primary = Color(0xFFFF8C42);
  static const Color accent = Color(0xFFFFD166);
  static const Color background = Color(0xFF151118);
  static const Color surface = Color(0xFF251C2B);
  static const Color surfaceAlt = Color(0xFF2E2436);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF3B1D2E), Color(0xFF1C1018)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
