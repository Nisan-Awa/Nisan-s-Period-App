import 'package:flutter/material.dart';

export 'data_model/app_state.dart';
export 'presentation/app.dart';

import 'presentation/app.dart' as presentation;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const presentation.PeriodTrackerApp());
}
