import 'package:flutter/material.dart';
import 'package:PenaAventura/homepage.dart';
import 'package:PenaAventura/views/login.dart';

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
        '/homepage': (context) => HomePage(),
      },
    );
  }
}
