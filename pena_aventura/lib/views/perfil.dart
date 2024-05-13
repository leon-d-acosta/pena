import 'dart:convert';

import 'package:PenaAventura/cor.dart';
import 'package:PenaAventura/views/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  late Future<List<dynamic>> _perfilData;

  @override
  void initState() {
    _refreshView(); // Llamada para actualizar el estado al iniciar
    super.initState();
  }

  void _refreshView() {
    setState(() {
      _perfilData = _getData(); // Llama a _getData() para obtener los datos actualizados
    });
  }

 /* void ScaffoldChanger(String field, snap) {
  WidgetBuilder bottom = (BuildContext context) {
    switch (field) {
      case 'nome':
        return ChangeNomeAlert(nome: snap);
      case 'apelido':
        return ChangeApelido(apelido: snap);
      default:
        throw Exception('Invalid field: $field');
    }
  };

  Navigator.push(context, MaterialPageRoute(builder: bottom))
    .then((value) {
      _refreshView(); // Llama a _refreshView() después de que ChangeLocalidadeAlert se cierre
    });
}*/


  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: ((context) => Login())),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Container(
            color: Cor.cinza,
            height: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.account_circle, color: Cor.azul_1, size: 100),
                        Text("M E U     P E R F I L", style: TextStyle(color: Cor.azul_1, fontSize: 30)),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 5),
                  child: FutureBuilder(
                    future: _perfilData,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error fetching data"),
                        );
                      }
                      List snap = snapshot.data;
                      List<String> fields = ['nome', 'apelido', 'email'];
                      return Container(
                        decoration: BoxDecoration(
                          color: Cor.verde_1,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          itemCount: fields.length,
                          itemBuilder: (context, index) {
                            String field = fields[index];
                            return GestureDetector(
                              onTap: () {
                                if (field != 'email') {
                                  print("object");
                                  //ScaffoldChanger(field, snap[0][field]);
                                }
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: ListTile(
                                  title: Text(
                                    snap[0][field],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  trailing: field !='email'? Icon(Icons.arrow_forward_ios, color: Colors.white,): Icon(Icons.alternate_email, color: Colors.white,)
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 15,
            right: 20,
            child: GestureDetector(
              onTap: _logout,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(10),
                child: const Row(
                  children: [
                    Text(
                      'LOGOUT  ',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.logout,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt('id') ?? 0;

    var url = Uri.parse('https://lavandaria.oxb.pt/index.php/get_perfil_app');
    //var url = Uri.parse('http://10.0.0.53/xampp/project_oxb/project1/lib/pages/db/perfil_db/perfil.php');
    var response = await http.post(url, body: {'id_utilizador': id.toString()});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos');
    }
  }
}