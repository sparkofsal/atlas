import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.loadData(); // ✅ correct method

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const BeliefAtlasApp(),
    ),
  );
}