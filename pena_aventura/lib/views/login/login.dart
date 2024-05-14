import 'dart:convert';

import 'package:PenaAventura/views/cores/cor.dart';
import 'package:PenaAventura/views/navbar/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatelessWidget {
  Login({Key? key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginFunction(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Datos insuficientes'),
      ));
      return;
    }

    var url = Uri.parse('https://lavandaria.oxb.pt/index.php/login_entrar');
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
    prefs.setBool('isLoggedIn', true); // Actualiza el estado de inicio de sesión
    prefs.setInt('id', int.parse(decodedData['utilizador']['id']));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(decodedData['status_message'] ?? 'Error desconocido'),
    ));
  }
} else {
  print("aqui rompe");
}
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error de conexión: ${response.statusCode} - ${response.reasonPhrase}'),
      ));
      print('Error de conexión: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: c.cinza,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle_rounded, color: c.azul_1, size: 150,),
              const Text("L O G I N", style: TextStyle(color: c.azul_1, fontSize: 20, fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(left: 40, right: 40),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        primaryColor: c.azul_1,
                        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                          iconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                            if (states.contains(MaterialState.focused)) {
                              return c.azul_1;
                            }
                            if (states.contains(MaterialState.error)) {
                              return c.azul_1;
                            }
                            return Colors.grey;
                          }),
                        ),
                      ),
                      child: TextField(
                        controller: emailController,
                        cursorColor: c.preto,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelStyle: TextStyle(color: c.preto),
                          icon: Icon(Icons.person),
                          label: Text("Correo eletronico"),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(left: 40, right: 40),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        primaryColor: c.azul_1,
                        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                          iconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                            if (states.contains(MaterialState.focused)) {
                              return c.azul_1;
                            }
                            if (states.contains(MaterialState.error)) {
                              return c.azul_1;
                            }
                            return Colors.grey;
                          }),
                        ),
                      ),
                      child: TextField(
                        controller: passwordController,
                        cursorColor: c.preto,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelStyle: TextStyle(color: c.preto),
                          icon: Icon(Icons.lock),
                          label: Text("Palavra-passe"),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              GestureDetector(
                onTap: () => loginFunction(context),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(left: 40, right: 40),
                  decoration: BoxDecoration(
                    color: c.verde_1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text("Enviar", style: TextStyle(color: c.branco, fontWeight: FontWeight.bold, fontSize: 15),)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
