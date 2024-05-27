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

    var url = Uri.parse('https://adminpena.oxb.pt/index.php/getpostosapp');
    var response  = await http.post(url, body: {'id': id.toString()});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.branco,
      body: Padding(
        padding: const EdgeInsets.all(10),
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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Qr_Scanner(id_posto: snap[index]['id'],))),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: c.cinza_2,
    
                    ),
                    width: MediaQuery.of(context).orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.5 - 15 
                        : MediaQuery.of(context).size.width * 0.25 - 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: MediaQuery.of(context).size.height/6, child: ClipRRect(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)), child: Image.network(snap[index]['foto'], fit: BoxFit.cover,))),
                        Container(margin: const EdgeInsets.only(left: 20, right: 20), child: Center(child: Text(snap[index]['nome'], style: TextStyle(color: c.branco, fontSize: 15 ),))),
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