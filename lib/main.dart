import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/tracking_provider.dart';
import 'ui/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
      ],
      child: const JustMyCycleApp(),
    ),
  );
}

class JustMyCycleApp extends StatelessWidget {
  const JustMyCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just My Cycle',
      theme: AppTheme.slateAndSage,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
