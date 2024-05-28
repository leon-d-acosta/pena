import 'package:flutter/material.dart';
import 'package:PenaAventura/views/navbar/homepage.dart';
import 'package:PenaAventura/views/login/login.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}
class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
      routes: {
        '/login': (context) =>  Login(),
        '/homepage': (context) =>  HomePage(),
      },
    );
  }
}
