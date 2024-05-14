import 'package:flutter/material.dart';
import 'package:PenaAventura/views/navbar/homepage.dart';
import 'package:PenaAventura/views/login/login.dart';

void main() {runApp(const MyApp());}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(),
        '/homepage': (context) => const HomePage()
      },
    );
  }
}
