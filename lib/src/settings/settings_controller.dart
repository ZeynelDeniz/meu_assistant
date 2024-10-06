import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_service.dart';

class SettingsController extends GetxController {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;
  var themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    themeMode.value = await _settingsService.themeMode();
  }

  Future<void> updateThemeMode(ThemeMode newThemeMode) async {
    if (newThemeMode == themeMode.value) return;
    themeMode.value = newThemeMode;
    await _settingsService.updateThemeMode(newThemeMode);
  }
}
