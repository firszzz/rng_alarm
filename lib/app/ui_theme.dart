import 'package:flutter/material.dart';

/// Color palette of the application
///
/// The current palette is [UITheme.dark]. A light palette is another constant of this type, installed as [ThemeData] later
class UITheme extends ThemeExtension<UITheme> {
  const UITheme({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.secondaryText,
    required this.disabledTime,
    required this.destructiveSurface,
    required this.onDestructive,
    required this.accent,
    required this.onAccent,
  });

  /// Dark palette used by the application now
  static const dark = UITheme(
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    onSurface: Color(0xFFFFFFFF),
    secondaryText: Color(0x8AFFFFFF),
    disabledTime: Color(0x62FFFFFF),
    destructiveSurface: Color(0xFF3A1C1C),
    onDestructive: Color(0xB3FFFFFF),
    accent: Color(0xFF34C759),
    onAccent: Color(0xFFFFFFFF),
  );

  /// Whether this palette is for a dark or light surrounding
  final Brightness brightness;

  /// Scaffold and app bar background
  final Color background;

  /// Card and sheet background
  final Color surface;

  /// Primary text and enabled alarm time
  final Color onSurface;

  /// Secondary text, such as the alarm name
  final Color secondaryText;

  /// Alarm time when the alarm is switched off
  final Color disabledTime;

  /// Background revealed by swiping an alarm away
  final Color destructiveSurface;

  /// Icon on [destructiveSurface]
  final Color onDestructive;

  /// Accent used by the add button and the color scheme seed
  final Color accent;

  /// Icon and text drawn on [accent]
  final Color onAccent;

  /// Palette installed on the nearest [Theme]
  ///
  /// Throws [FlutterError] when [toThemeData] was not used for this context
  static UITheme of(BuildContext context) {
    final theme = Theme.of(context).extension<UITheme>();
    if (theme == null) {
      throw FlutterError('UITheme is missing from ThemeData');
    }
    return theme;
  }

  /// Material theme that carries this palette
  ThemeData toThemeData() {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: brightness),
      extensions: [this],
      appBarTheme: AppBarTheme(backgroundColor: background, foregroundColor: onSurface),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: accent, foregroundColor: onAccent),
    );
  }

  @override
  UITheme copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? secondaryText,
    Color? disabledTime,
    Color? destructiveSurface,
    Color? onDestructive,
    Color? accent,
    Color? onAccent,
  }) {
    return UITheme(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      secondaryText: secondaryText ?? this.secondaryText,
      disabledTime: disabledTime ?? this.disabledTime,
      destructiveSurface: destructiveSurface ?? this.destructiveSurface,
      onDestructive: onDestructive ?? this.onDestructive,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  UITheme lerp(ThemeExtension<UITheme>? other, double t) {
    if (other is! UITheme) {
      return this;
    }

    return UITheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      onSurface: Color.lerp(onSurface, other.onSurface, t) ?? onSurface,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t) ?? secondaryText,
      disabledTime: Color.lerp(disabledTime, other.disabledTime, t) ?? disabledTime,
      destructiveSurface: Color.lerp(destructiveSurface, other.destructiveSurface, t) ?? destructiveSurface,
      onDestructive: Color.lerp(onDestructive, other.onDestructive, t) ?? onDestructive,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      onAccent: Color.lerp(onAccent, other.onAccent, t) ?? onAccent,
    );
  }
}
