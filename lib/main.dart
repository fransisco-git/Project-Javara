import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme.dart';
import 'features/home/home_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final isLoggedIn = await AuthService.instance.isLoggedIn().catchError((_) => false);
  runApp(JavaraApp(isLoggedIn: isLoggedIn));
}

class JavaraApp extends StatelessWidget {
  const JavaraApp({super.key, this.isLoggedIn = false});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Javara',
      debugShowCheckedModeBanner: false,
      theme: buildJavaraTheme(),
      home: isLoggedIn
          ? const HomeScreen()
          : const WelcomeScreen(playGateOpen: true),
    );
  }
}
