import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'services/connectivity_service.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = Get.put(SettingsController(SettingsService()));
  Get.put(ConnectivityService());

  await settingsController.loadSettings();

  runApp(const MyApp());
}
