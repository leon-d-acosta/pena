import 'dart:convert';

import 'package:PenaAventura/views/cores/cor.dart';
import 'package:flutter/material.dart';
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
  int variable2 = 0;

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
    body: FutureBuilder(
      future: _futureBuilder,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error fetching data"),
          );
        }
        List snap = snapshot.data;
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                for (var task in snap) ...[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    color: Colors.amber,
                    child: Center(
                      child: Text(task['tarefa_nome']),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
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
                                  Text(task['tarefa_nome'], style: TextStyle(color: c.preto, fontSize: 15)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Manhã', style: TextStyle(color: c.laranja, fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text(task['tarefa_nome'], style: TextStyle(color: c.preto, fontSize: 15)),
                                ],
                              ),
                        GestureDetector(
                          child: Container(
                            width: MediaQuery.of(context).size.height / 4.5,
                            height: MediaQuery.of(context).size.height / 15,
                            decoration: BoxDecoration(
                              color: c.verde_2,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(margin: const EdgeInsets.only(left: 15), child: Text("Alterar Sessão", style: TextStyle(color: c.branco, fontWeight: FontWeight.bold, fontSize: 15))),
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
                            ],
                          ),
                        ),
                        Divider(
                          color: c.preto.withOpacity(0.2),
                          height: 25,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      child: Text("Compradas: ${task['tarefa_nome']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      child: Text("Concluidas: ${task['tarefa_nome']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      child: Text("Anuladas: $variable2", style: TextStyle(fontSize: 15, color: c.preto)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      child: Text("Não concluidas: ${task['tarefa_nome']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                    ),
                                  ],
                                )
                              ],
                            ),
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
                          margin: const EdgeInsets.only(top: 15, bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              
                              GestureDetector(
                                onTap: () { 
                                  setState(() {});
                                  print("asdasdasdasd");},
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
                                        child: Icon(Icons.close, color: c.branco),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  variable2 = variable;
                                  setState(() {
                                    
                                  });
                                  },
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
                                      Container(margin: const EdgeInsets.only(left: 20), child: Text("Registar", style: TextStyle(color: c.branco, fontWeight: FontWeight.bold, fontSize: 15))),
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
                            ],
                          ),
                        ),

                        Divider(
                          color: c.preto.withOpacity(0.2),
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => Navigator.pop(context),
      foregroundColor: c.branco,
      backgroundColor: c.azul_1,
      child: Icon(Icons.arrow_back),
    ),
  );
}

Future<int?> _getid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<List<dynamic>> _getData() async {
    int id = (await _getid()) ?? 0;
    print(id);

    var url = Uri.parse('https://lavandaria.oxb.pt/index.php/get_tarefas_app');
    var response  = await http.post(url, body: {'id': id.toString()});

    if (response.statusCode == 200) {
      print("objectasdasda  asdasd");
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos 233');
    }
  }
}
