import 'dart:convert';

import 'package:PenaAventura/views/cores/cor.dart';
import 'package:PenaAventura/views/login/login.dart';
import 'package:PenaAventura/views/perfil/updates_perfil/updateApelido.dart';
import 'package:PenaAventura/views/perfil/updates_perfil/updateNome.dart';
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

 void ScaffoldChanger(String field, snap) {
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
}


  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('email');
    await prefs.remove('palavra-passe');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: ((context) => Login())),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: c.cinza,
          height: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child:  Center(
                  child: Column(
                    children: [
                      Icon(Icons.account_circle, color: c.azul_1, size: MediaQuery.of(context).orientation == Orientation.portrait
                                                                                                                    ? 100
                                                                                                                    : 50),
                      Text("M E U     P E R F I L", style: TextStyle(color: c.azul_1, fontSize: MediaQuery.of(context).orientation == Orientation.portrait
                                                                                                                                            ? 30
                                                                                                                                            : 25)),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                height: MediaQuery.of(context).orientation == Orientation.portrait
                                                                            ?MediaQuery.of(context).size.height / 4.75
                                                                            :MediaQuery.of(context).size.height / 2.15,
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
                        color: c.azul_1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(fields.length, (index) {
                          String field = fields[index];
                          return GestureDetector(
                            onTap: () {
                              if (field != 'email') {
                                ScaffoldChanger(field, snap[0][field]);
                              }
                            },
                            child: ListTile(
                              title: Text(
                                snap[0][field],
                                style: const TextStyle(color: c.branco),
                              ),
                              trailing: field != 'email' ? const Icon(Icons.arrow_forward_ios, color: c.branco,) : const Icon(Icons.alternate_email, color: c.branco,),
                            ),
                          );
                        }),
),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
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
                    style: TextStyle(color: c.branco, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.logout,
                    size: 20,
                    color: c.branco,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<dynamic>> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt('id') ?? 0;

    var url = Uri.parse('https://lavandaria.oxb.pt/index.php/get_perfil_app');
    var response = await http.post(url, body: {'id_utilizador': id.toString()});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos');
    }
  }
}