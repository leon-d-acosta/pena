import 'package:flutter/material.dart';
import 'package:PenaAventura/views/navbar/homepage.dart';
import 'package:PenaAventura/views/login/login.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}
class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() { // Método chamado ao inicializar o estado
    super.initState(); // Chama o método initState da classe pai
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Define a orientação do dispositivo para retrato
  }

  @override
  void dispose() { // Método chamado ao descartar o estado
    SystemChrome.setPreferredOrientations([ // Define as orientações preferidas do dispositivo
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.dispose(); // Chama o método dispose da classe pai
  }

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
