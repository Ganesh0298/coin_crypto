import 'package:flutter/material.dart';

class ColorResource {
  static const appThemeColor1 = Color(0xFF2563EB);
  static const appThemeColor2 = Color(0xFF7C3AED);
  static const appThemeTextColor = Color(0xFF00236F);

  static const unselectedLabelColor = Color(0xFF7B7B7B);
  static const textInputColor = Color(0xFF272727);
  static const formBorderColor = Color(0xFFE4E4E4);

  static const appBgColor = Color(0xFFFFFFFF);
  static const appMainBgColor = Color(0xFFF4F4F8);
  static const errorTextColor = Color(0xFFE53935);
  static const activeColor = Color(0xFF2E7D32);
  static const encashmentColor = Color(0xFFE89271);
  static const frequencyColor = Color(0xFFF0C274);
  static const carryForwardColor = Color(0xFF70A1E5);
  static const approvalColor = Color(0xFF3EC793);
  static const pendingNewColor = Color(0xFFD97706);

  // Dashboard semantic colors
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const neutral = Color(0xFF64748B);

  // Text
  static const textPrimary = Color(0xFF272727);
  static const textSecondary = Color(0xFF7B7B7B);

  // Surfaces
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE4E4E4);

  // Primary
  static const primary = appThemeColor1;
  static const primaryDark = Color(0xFF1D4ED8);

  // Softer tints of the two brand colors — used to build the icon
  // gradient so badges don't read as "just the button color again".
  static const _iconTint1 = Color(0xFF60A5FA); // lighter blue
  static const _iconTint2 = Color(0xFFA78BFA); // lighter violet

  // Deep tone folded into the header gradient for extra depth.
  static const _headerDeep = Color(0xFF4C1D95); // deep violet

  static const primaryGradient = LinearGradient(
    colors: [
      appThemeColor1,
      appThemeColor2,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// For full-bleed hero headers (dashboards, screen tops). Same blue/violet
  /// family as primaryGradient but a 3-stop diagonal on a different axis, so
  /// headers read as their own surface rather than one big button.
  static const headerGradient = LinearGradient(
    colors: [appThemeColor1, appThemeColor2, _headerDeep],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomRight,
  );

  /// For icon badges / crown circles / feature icons — a lighter,
  /// vertical gradient so icons feel like accents, not duplicate buttons.
  static const iconGradient = LinearGradient(
    colors: [_iconTint1, _iconTint2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// For the Month/Year (or any segmented) toggle's selected pill —
  /// horizontal and reversed from primaryGradient so it reads as its
  /// own element rather than a smaller copy of the CTA button.
  static const toggleGradient = LinearGradient(
    colors: [appThemeColor2, appThemeColor1],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}