import 'dart:convert';
import 'package:PenaAventura/views/cores/cor.dart';
import 'package:PenaAventura/views/navbar/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  Login({super.key});
  
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? email, palavra_passe;
  bool _showPopup = false; // Bandera para controlar la visualización del popup

  @override
  void initState() {
    super.initState();
    _showPopup = false; // Inicialmente el popup no se muestra
    RememberMe(); // Verifica el inicio de sesión automático si hay credenciales guardadas
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mostrar el popup solo una vez después de que initState ha completado
    if (!_showPopup) {
      _showPopup = true;
      showPopup(); // Llama al método para mostrar el popup
    }
  }

  void showPopup() async {
    await Future.delayed(Duration(milliseconds: 50));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Aviso"),
          content: Text("Texto de tu popup aquí"),
          actions: <Widget>[
            TextButton(
              child: Text("Ir a tu URL"),
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí deberías navegar a tu URL deseada
                // Ejemplo:
                // Navigator.pushNamed(context, '/tu_ruta');
              },
            ),
          ],
        );
      },
    );
  }

  RememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    palavra_passe = prefs.getString('palavra-passe');
    if (email != null && palavra_passe != null) {
      setState(() {
        emailController.text = email!;
        passwordController.text = palavra_passe!;
      });
    } else {
      print("Sin mail ni passe");
    }
  }

  Future<void> loginFunction(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(
          child: Text(
            'Datos insuficientes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }

    var url = Uri.parse('https://adminpena.oxb.pt/index.php/loginentrar');
    final response = await http.post(
      url,
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      var decodedData;
      try {
        decodedData = json.decode(response.body);
      } catch (e) {
        print('Error al decodificar la respuesta del servidor: $e');
      }

      if (decodedData != null && decodedData['status'] != null) {
        if (decodedData['status'] == 'success' || decodedData['status'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('id', int.parse(decodedData['utilizador']['id']));
          prefs.setString('email', emailController.text);
          prefs.setString('palavra-passe', passwordController.text);
          Navigator.pushReplacementNamed(context, '/homepage'); // Navega a la página de inicio y reemplaza la pila de navegación
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Center(
              child: Text(
                decodedData['status_message'] ?? 'Error desconocido',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        print("aqui rompe");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Error de conexión: ${response.statusCode} - ${response.reasonPhrase}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
      ));
      print('Error de conexión: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 1.5,
            width: MediaQuery.of(context).size.width / 1.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/imagens/logo_branco.png'),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    GestureDetector(
                      onTap: () => loginFunction(context),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            "Iniciar sessão",
                            style: TextStyle(color: Colors.white, fontSize: 21),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
