import 'dart:convert';

import 'package:PenaAventura/views/cores/cor.dart';
import 'package:PenaAventura/views/postos/qr_tarefa/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Postos extends StatefulWidget {
  const Postos({super.key});

  @override
  State<Postos> createState() => _PostosState();
}

class _PostosState extends State<Postos> {
  late Future<List<dynamic>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _getData();
  }

  Future<int?> _getid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

Future<List<dynamic>> _getData() async {
    int id = (await _getid()) ?? 0;

    var url = Uri.parse('https://lavandaria.oxb.pt/index.php/get_tarefas_app');
    var response  = await http.post(url, body: {'id': id.toString()});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos 233');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.cinza,
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: FutureBuilder(
          future: _futureData,
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"),);
            }
            List<dynamic> snap = snapshot.data!;
            return GridView.builder(
              itemCount: snap.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15
              ), 
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Qr_Scanner(nome_atividade: snap[index]['tarefa_nome'],))),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: snap[index]['estado'] == 0
                              ?Colors.grey
                              :c.azul_1,
    
                    ),
                    width: MediaQuery.of(context).orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.5 - 15 
                        : MediaQuery.of(context).size.width * 0.25 - 15,
                    child: Column(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)), child: Image.network("https://packs.lifecooler.com/wondermedias/sys_master/productmedias/h6b/hbe/661534-560x373.jpg")),
                        Container(margin: const EdgeInsets.only(left: 20, right: 20), child: Text(snap[index]['tarefa_nome'], style: TextStyle(
                                                                                                                                          color: snap[index]['estado']==0
                                                                                                                                                         ?c.preto
                                                                                                                                                         :c.branco,
                                                                                                                                          fontSize: 18
                                                                                                                                          ),)),
                      ],
                    ),
                  ),
                );
              },
            );
    
          }
        ),
      ),
    );
  }
}