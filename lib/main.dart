import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/app_state.dart';
import 'services/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AnalyticsService().logAppOpen();
  AnalyticsService().logSessionStart();

  final appState = AppState();
  await appState.loadData();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const BeliefAtlasApp(),
    ),
  );
}