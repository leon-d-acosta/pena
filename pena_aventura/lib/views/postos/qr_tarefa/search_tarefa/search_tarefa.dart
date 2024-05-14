import 'dart:convert';

import 'package:PenaAventura/views/cores/cor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchTarefa extends StatefulWidget {
  final String nome_atividade;
  const SearchTarefa({Key? key, required this.nome_atividade}) : super(key: key);

  @override
  State<SearchTarefa> createState() => _SearchTarefaState();
}

class _SearchTarefaState extends State<SearchTarefa> {
  late Future<List<dynamic>> _futureBuilder;
  int variable = 0;

  @override
  void initState() {
    _refreshView(); // Llamada para actualizar el estado al iniciar
    super.initState();
  }

  void _refreshView() {
    setState(() {
      _futureBuilder = _getData(); // Llama a _getData() para obtener los datos actualizados
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.cinza,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3,
            color: Colors.amber,
            child: Center(
              child: Text("Imagem"),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: FutureBuilder(
                        future: _futureBuilder,
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.nome_atividade, style: TextStyle(color: c.preto, fontWeight: FontWeight.bold, fontSize: 18)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Data", style: TextStyle(color: c.laranja, fontSize: 20, fontWeight: FontWeight.bold)),
                                        Text(snap[0]['nome'], style: TextStyle(color: c.preto, fontSize: 15)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Manhã', style: TextStyle(color: c.laranja, fontSize: 20, fontWeight: FontWeight.bold)),
                                        Text(snap[0]['apelido'], style: TextStyle(color: c.preto, fontSize: 15)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  height: MediaQuery.of(context).size.height / 15,
                                  decoration: BoxDecoration(
                                    color: c.verde_2,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: const EdgeInsets.only(left: 40), child: Text("Alterar Sessão", style: TextStyle(color: c.branco, fontWeight: FontWeight.bold, fontSize: 15))),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: c.verde_1,
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                                        ),
                                        height: MediaQuery.of(context).size.height / 15,
                                        width: MediaQuery.of(context).size.height / 15,
                                        child: Icon(Icons.bolt, color: c.branco),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                color: c.preto.withOpacity(0.2),
                                height: 25,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: Text("Compradas: ${snap[0]['nome']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: Text("Concluidas: ${snap[0]['nome']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: Text("Anuladas: ${snap[0]['nome']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: Text("Não concluidas: ${snap[0]['nome']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                  )
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: c.preto.withOpacity(0.05),
                                  border: Border.all(color: c.preto, width: 0.5),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                height: MediaQuery.of(context).size.height / 15,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (variable > 0) {
                                          setState(() {
                                            variable--;
                                          });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: c.preto.withOpacity(0.2),
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                                        ),
                                        width: MediaQuery.of(context).size.height / 15,
                                        height: MediaQuery.of(context).size.height / 15,
                                        child: Icon(Icons.remove),
                                      ),
                                    ),
                                    Text("$variable"),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          variable++;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: c.preto.withOpacity(0.2),
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                                        ),
                                        width: MediaQuery.of(context).size.height / 15,
                                        height: MediaQuery.of(context).size.height / 15,
                                        child: Icon(Icons.add),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: c.azul_1,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        width: MediaQuery.of(context).size.width / 2.25,
                                        height: MediaQuery.of(context).size.height / 15,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(margin: const EdgeInsets.only(left: 20), child: Text("Registrar", style: TextStyle(color: c.branco, fontWeight: FontWeight.bold, fontSize: 15))),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: c.azul_2,
                                                borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                                              ),
                                              height: MediaQuery.of(context).size.height / 15,
                                              width: MediaQuery.of(context).size.height / 15,
                                              child: Icon(Icons.arrow_forward_outlined, color: c.branco),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: c.laranja,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        width: MediaQuery.of(context).size.width / 2.2,
                                        height: MediaQuery.of(context).size.height / 15,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(margin: const EdgeInsets.only(left: 20), child: Text("Anular", style: TextStyle(color: c.branco, fontWeight: FontWeight.bold, fontSize: 15))),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: c.laranja_2,
                                                borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                                              ),
                                              height: MediaQuery.of(context).size.height / 15,
                                              width: MediaQuery.of(context).size.height / 15,
                                              child: Icon(Icons.arrow_upward, color: c.branco),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        foregroundColor: c.branco,
        backgroundColor: c.azul_1,
        child: Icon(Icons.arrow_back),
      ),
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
