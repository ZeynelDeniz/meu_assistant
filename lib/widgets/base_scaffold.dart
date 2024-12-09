import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../services/connectivity_service.dart';
import '../src/settings/settings_controller.dart';
import 'app_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BaseScaffold extends StatelessWidget {
  const BaseScaffold({
    super.key,
    required this.body,
    this.appBarTitle,
    this.fab,
    this.appBarActions,
  });

  final Widget body;
  final String? appBarTitle;
  final Widget? fab;
  final List<Widget>? appBarActions;

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final connectivityService = Get.find<ConnectivityService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle ?? 'App'),
        actions: appBarActions,
      ),
      drawer: AppDrawer(settingsController: settingsController),
      body: Obx(() {
        return Column(
          children: [
            if (connectivityService.isConnected.value == false)
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                color: Colors.red,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.noConnection,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: body,
            ),
            if (Platform.isIOS)
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              ),
          ],
        );
      }),
      floatingActionButton: fab,
    );
  }
}
