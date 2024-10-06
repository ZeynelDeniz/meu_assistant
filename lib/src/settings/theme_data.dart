import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
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
    bodyLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
    bodyMedium: TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
  ),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color.fromARGB(255, 235, 235, 235),
    secondary: const Color.fromARGB(255, 45, 45, 45),
    tertiary: const Color.fromARGB(255, 80, 80, 80),
    surface: const Color.fromARGB(255, 250, 250, 250),
  ),
  dividerTheme: const DividerThemeData(
    color: Color.fromARGB(255, 200, 200, 200),
    thickness: 1,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: const Color.fromARGB(255, 45, 45, 45)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: const Color.fromARGB(255, 45, 45, 45)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(255, 33, 150, 243)),
    ),
  ),
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  brightness: Brightness.dark,
  primaryColor: const Color.fromARGB(255, 30, 30, 30), // Same accent color
  scaffoldBackgroundColor: const Color.fromARGB(255, 45, 45, 45),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 30, 30, 30), // Dark grey app bar
    iconTheme: IconThemeData(color: Colors.white),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color.fromARGB(255, 255, 193, 7), // Amber buttons
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.amber),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
    bodyMedium: TextStyle(color: Color.fromARGB(179, 255, 255, 255)),
  ),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color.fromARGB(255, 30, 30, 30),
    secondary: const Color.fromARGB(255, 255, 193, 7),
    tertiary: const Color.fromARGB(255, 150, 150, 150),
    surface: const Color.fromARGB(255, 45, 45, 45),
  ),
  dividerTheme: const DividerThemeData(
    color: Color.fromARGB(255, 235, 235, 235),
    thickness: 1,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: const Color.fromARGB(255, 235, 235, 235)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: const Color.fromARGB(255, 235, 235, 235)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: const Color.fromARGB(255, 33, 150, 243)),
    ),
  ),
);
