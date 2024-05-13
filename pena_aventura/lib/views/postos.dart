import 'dart:convert';

import 'package:PenaAventura/cor.dart';
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
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: Cor.cinza,
        body: Padding(
          padding: const EdgeInsets.all(20),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 8
                ), 
                itemBuilder: (context, index) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Cor.verde_1,
                    child: Center(
                      child: Text(snap[index]['tarefa_nome']),
                    ),
                  );
                },
                );
            }
          ),
        ),
      ),
    );
  }
}