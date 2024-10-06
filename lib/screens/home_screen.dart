import 'package:flutter/material.dart';

import '../widgets/base_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      appBarTitle: 'Home',
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
