import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(255, 235, 235, 235), // Accent similar to dark theme
  scaffoldBackgroundColor: const Color.fromARGB(255, 250, 250, 250),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 235, 235, 235), // Light grey app bar
    iconTheme: IconThemeData(color: Colors.black),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.white,
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(
        const Color.fromARGB(255, 45, 45, 45),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.light,
  ).copyWith(
    secondary: const Color.fromARGB(255, 45, 45, 45),
    primary: const Color.fromARGB(255, 235, 235, 235),
    surface: const Color.fromARGB(255, 250, 250, 250),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color.fromARGB(255, 30, 30, 30), // Same accent color
  scaffoldBackgroundColor: const Color.fromARGB(255, 45, 45, 45),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 30, 30, 30), // Dark grey app bar
    iconTheme: IconThemeData(color: Colors.white),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.amber, // Amber buttons
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.amber),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
  ).copyWith(
    secondary: Colors.amber,
    primary: const Color.fromARGB(255, 30, 30, 30),
    surface: const Color.fromARGB(255, 45, 45, 45),
  ),
);
