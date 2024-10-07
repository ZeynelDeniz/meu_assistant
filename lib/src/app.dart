import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:meu_assistant/screens/home_screen.dart';
import 'package:meu_assistant/screens/map_screen.dart';

import '../screens/chat_screen.dart';
import 'settings/settings_controller.dart';
import 'settings/theme_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        // Provide the generated AppLocalizations to the MaterialApp. This
        // allows descendant Widgets to display the correct translations
        // depending on the user's locale.
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('tr', ''), // Turkish, no country code
        ],
        locale: settingsController.locale.value, // Use the locale from SettingsController

        // Use AppLocalizations to configure the correct application title
        // depending on the user's locale.
        //
        // The appTitle is defined in .arb files found in the localization
        // directory.
        onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,

        // Using custom light and dark themes
        theme: lightTheme, // Your custom light theme
        darkTheme: darkTheme, // Your custom dark theme
        themeMode: settingsController.themeMode.value,
        initialRoute: HomeScreen.routeName,
        getPages: [
          GetPage(
            name: HomeScreen.routeName,
            page: () => const HomeScreen(),
          ),
          GetPage(
            name: ChatScreen.routeName,
            page: () => ChatScreen(),
          ),
          GetPage(
            name: MapScreen.routeName,
            page: () => MapScreen(),
          ),
        ],
      );
    });
  }
}
