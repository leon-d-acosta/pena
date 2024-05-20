import 'dart:convert';

import 'package:PenaAventura/views/cores/cor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchTarefa extends StatefulWidget {
  final String id_posto;
  final String qr;

  // Constructor para recibir o nome da atividad
  const SearchTarefa({Key? key, required this.id_posto, required this.qr}) : super(key: key);

  @override
  State<SearchTarefa> createState() => _SearchTarefaState();
}

class _SearchTarefaState extends State<SearchTarefa> {
  late Future<List<dynamic>> _futureBuilder; // Variable para almacenar o futuro que obtiene os datos
  int variable = 0; // Variable de contador para algún propósito
  int variable2 = 0; // Otra variable de contador

  @override
  void initState() {
    _refreshView(); // Llamada para atualizar o estado ao iniciar
    super.initState();
  }

  void _refreshView() {
    setState(() {
      _futureBuilder = _getData(); // Llama a _getData() para obtener os dados atualizados
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.cinza, // Cor de fondo do scaffold
      body: FutureBuilder(
        future: _futureBuilder, // Futuro que se está esperando
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // Mostra um indicador de progreso encuanto espera
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          // Mostra uma mensagem de erro se acontece um
          if (snapshot.hasError) {
            return Center(
              child: Text("Error fetching data"),
            );
          }
          List snap = snapshot.data; // Datos obtenidos do snapshot
          if (snap.isEmpty) {
            return Center(
              child: Container(
                child: Text("aaa"),
              ),
            );
          }
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(bottom: 20), // Espaciado na parte inferior
              child: Column(
                children: [
                  for (var task in snap) ...[
                    // Contentor para cada atividade
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3,
                      color: c.cinza, // Cor de fondo do contentor
                      child: Image.network(task['foto'], fit: BoxFit.cover,),
                    ),
                    // Contentor com detalhes da atividade
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome da atividade
                          Text(task['nome_produto'], style: TextStyle(color: c.preto, fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(task['nome_produto_principal'], style: TextStyle(color: c.preto, fontSize: 15),),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Columna com a data
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Data", style: TextStyle(color: c.laranja, fontSize: 20, fontWeight: FontWeight.bold)),
                                    Text(task['data_atividade'], style: TextStyle(color: c.preto, fontSize: 15)),
                                  ],
                                ),
                                // Columna com informação adicional da atividade
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task['nome_sessao'], style: TextStyle(color: c.laranja, fontSize: 20, fontWeight: FontWeight.bold)),
                                    Text("${task['hora']}H", style: TextStyle(color: c.preto, fontSize: 15)),
                                  ],
                                ),
                                // Botão para alterar a sessão
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: c.verde_2,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
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
                          
                          Divider(color: c.preto.withOpacity(0.2), height: 25), // Línea divisoria

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Informacão das atividades compradas e concluidas
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        child: Text("Compradas: ${task['quantidade']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        child: Text("Concluidas: ${task['utilizada']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                      ),
                                    ],
                                  ),
                                  // Informacão das atividades anuladas e não concluidas
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        child: Text("Anuladas: ${task['anuladas']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        child: Text("Não concluidas: ${task['nao_concluidas']}", style: TextStyle(fontSize: 15, color: c.preto)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          
                          // Contador com botões para aumentar ou diminuir
                          Visibility(
                            visible: task['nao_concluidas'] > 0
                                                        ?true
                                                        :false,
                            child: Container(
                              decoration: BoxDecoration(
                                color: c.preto.withOpacity(0.05),
                                border: Border.all(color: c.preto, width: 0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              height: MediaQuery.of(context).size.height / 15,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Botão para diminuir a variable que vai mudar o valor das atividades concluidas
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
                                  Text("$variable"), // Muestra el valor de la variable
                                  // Botão para acrescentar a variable que vai mudar o valor das atividades concluidas
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
                          ),
                          Visibility(
                            visible: task['nao_concluidas']>0
                            ?true:false,
                            child: Container(
                              margin: const EdgeInsets.only(top: 15, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Botão para anular as atividades
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
                                  // Botão para registar as atividades concluidas
                                  GestureDetector(
                                    onTap: () {
                                      variable2 = variable;
                                      setState(() {});
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
                          ),
                          Visibility(
                            visible: task['nao_concluidas']<=0
                            ?true:false,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: c.verde_1.withOpacity(0.3),
                                    ),
                                    height: MediaQuery.of(context).size.height/15,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.task_alt_outlined),
                                        Text("Atividade realizada"),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: c.verde_2,
                                    ),
                                    height: MediaQuery.of(context).size.height/15,
                                    child: Center(child: Text("Processo concluido", style: TextStyle(color: c.branco),)),
                                  ),
                                ],
                              ),
                            )
                            ),

                          Divider(color: c.preto.withOpacity(0.2), height: 25,), // Línea divisoria

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
        onPressed: () => Navigator.pop(context), // Botón flotante para retroceder
        foregroundColor: c.branco,
        backgroundColor: c.azul_1,
        child: Icon(Icons.arrow_back),
      ),
    );
  }

  // Función para obtener el id del SharedPreferences
  Future<int?> _getid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  // Función para obtener los datos de la API
  Future<List<dynamic>> _getData() async {
    int id = (await _getid()) ?? 0;
    print(widget.qr);

    var url = Uri.parse('https://adminpena.oxb.pt/index.php/getatividadesapp');
    var response  = await http.post(url, body: {'id': id.toString(), 'id_posto': widget.id_posto.toString(), 'qrcode': widget.qr.toString()});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos 233');
    }
  }
}
