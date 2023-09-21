import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    iconTheme: IconThemeData(color: Colors.grey[900]),
    backgroundColor: Colors.grey[300],
    titleTextStyle: TextStyle(color: Colors.grey[900], fontSize: 20),
  ),
  colorScheme: ColorScheme.light(
    background: Colors.grey[300]!,
    primary: Colors.grey[200]!,
    secondary: Colors.grey[300]!,
    tertiary: Colors.grey[900]!,
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
);
