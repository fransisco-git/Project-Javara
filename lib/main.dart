import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const JavaraApp());
}

class JavaraApp extends StatelessWidget {
  const JavaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Javara',
      debugShowCheckedModeBanner: false,
      theme: buildJavaraTheme(),
      home: const SplashScreen(),
    );
  }
}
