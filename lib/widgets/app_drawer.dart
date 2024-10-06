import 'package:flutter/material.dart';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:get/get.dart';

import '../src/settings/settings_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              children: [
                Spacer(),
                Text(
                  'Meu Asistan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Tema",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(
                flex: 2,
              ),
              Expanded(
                flex: 5,
                child: Obx(() {
                  return IconTheme.merge(
                    data: const IconThemeData(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedToggleSwitch<int>.rolling(
                        current: settingsController.themeMode.value.index,
                        values: const [0, 1, 2],
                        onChanged: (index) {
                          ThemeMode newThemeMode;
                          switch (index) {
                            case 1:
                              newThemeMode = ThemeMode.light;
                              break;
                            case 2:
                              newThemeMode = ThemeMode.dark;
                              break;
                            case 0:
                            default:
                              newThemeMode = ThemeMode.system;
                              break;
                          }
                          settingsController.updateThemeMode(newThemeMode);
                          return Future.value();
                        },
                        height: 40,
                        iconBuilder: (value, foreground) {
                          final themeMode = settingsController.themeMode.value;
                          final isDarkMode = themeMode == ThemeMode.dark ||
                              (themeMode == ThemeMode.system &&
                                  View.of(context).platformDispatcher.platformBrightness ==
                                      Brightness.dark);

                          final color = foreground
                              ? Colors.white
                              : (isDarkMode ? Colors.white : Colors.black);

                          switch (value) {
                            case 1:
                              return Icon(Icons.light_mode, color: color);
                            case 2:
                              return Icon(Icons.dark_mode, color: color);
                            case 0:
                            default:
                              return Icon(Icons.brightness_auto, color: color);
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          ...screensInDrawer.map(
            (screen) {
              return ListTile(
                leading: screen.iconAsset != null
                    ? Image.asset(
                        screen.iconAsset!,
                        width: 24,
                        height: 24,
                      )
                    : Icon(
                        screen.icon,
                      ),
                title: Text(screen.dTitle),
                onTap: () async {
                  // Check if the current route is the same as the target route
                  if (Get.currentRoute == screen.dRoute) {
                    Get.back(); // Just close the drawer
                  } else {
                    Get.back();
                    Get.offAndToNamed(screen.dRoute); // Navigate to the new route
                  }
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.settings),
              label: const Text("Test Button"),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerItem {
  final String dTitle;
  final String dRoute;
  final String? iconAsset; // Asset yolu, opsiyonel
  final IconData? icon; // Standart ikon, opsiyonel

  DrawerItem({
    required this.dTitle,
    required this.dRoute,
    this.iconAsset,
    this.icon,
  });
}

final List<DrawerItem> screensInDrawer = [
  DrawerItem(dTitle: "Ana Sayfa", dRoute: "/", icon: Icons.home),
  DrawerItem(dTitle: "AI Asistan", dRoute: "/chat", icon: Icons.chat),
];
