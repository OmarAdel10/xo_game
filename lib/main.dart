import 'package:flutter/material.dart';
import 'package:xo_game_v2/main_screen.dart';
import 'package:xo_game_v2/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        MainScreen.routeName : (_) => MainScreen(),
        WelcomeScreen.routeName : (_) => WelcomeScreen(),
      },
      initialRoute: WelcomeScreen.routeName,
    );
  }
}