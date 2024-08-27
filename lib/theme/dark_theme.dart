import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

ThemeData darkTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
  ),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.black,
    primary: Colors.grey[900]!,
    secondary: Colors.grey[800]!,
    tertiary: Colors.white,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.blue),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.blue, // Set the caret (cursor) color
    selectionColor:
        Colors.blue.withOpacity(0.2), // Set the text selection color
    selectionHandleColor: Colors.blue, // Set the selection handle color
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colors.grey[300], // Set the color of the progress indicator
  ),
);

SettingsThemeData darkSettingsTheme = const SettingsThemeData(
  settingsListBackground: Colors.black,
);
