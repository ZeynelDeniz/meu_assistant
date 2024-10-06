import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../src/settings/settings_controller.dart';
import 'app_drawer.dart';

class BaseScaffold extends StatelessWidget {
  const BaseScaffold({
    super.key,
    required this.body,
    this.appBarTitle,
  });

  final Widget body;
  final String? appBarTitle;

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle ?? 'App'),
      ),
      drawer: AppDrawer(settingsController: settingsController),
      body: body,
    );
  }
}
