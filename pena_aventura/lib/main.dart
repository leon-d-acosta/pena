import 'package:flutter/material.dart';
import 'package:PenaAventura/views/navbar/homepage.dart';
import 'package:PenaAventura/views/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ?  HomePage() :  Login(),
      routes: {
        '/login': (context) =>  Login(),
        '/homepage': (context) =>  HomePage(),
      },
    );
  }
}
