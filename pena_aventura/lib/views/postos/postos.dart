import 'dart:convert';
import 'dart:io';

import 'package:PenaAventura/views/cores/cor.dart';
import 'package:PenaAventura/views/postos/qr_tarefa/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Postos extends StatefulWidget {
  const Postos({Key? key}) : super(key: key);

  @override
  State<Postos> createState() => _PostosState();
}

class _PostosState extends State<Postos> {
  late Future<List<dynamic>> _futureData;
  List<dynamic> _postos = [];
  String _searchQuery = "";

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
    var response = await http.post(url, body: {'id': id.toString()});

    if (response.statusCode == 200) {
      setState(() {
        _postos = json.decode(response.body);
      });
      return _postos;
    } else {
      throw Exception('Erro ao obter os dados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: c.cinza,
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: c.branco,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder(
                  future: _futureData,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("${snapshot.error}"));
                    }
                    List<dynamic> filteredPostos = _postos.where((posto) {
                      return posto['nome'].toLowerCase().contains(_searchQuery);
                    }).toList();
                    return Center(
                      child: GridView.builder(
                        itemCount: filteredPostos.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showDownloadPopup(context),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: c.azul_2.withOpacity(0.4),
                              ),
                              width: MediaQuery.of(context).size.width * 0.5 - 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height / 6,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                      ),
                                      child: Image.network(
                                        filteredPostos[index]['foto'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 20, right: 20),
                                    child: Center(
                                      child: Text(
                                        filteredPostos[index]['nome'],
                                        style: TextStyle(color: c.preto, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ],
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
      ),
    );
  }

  void _showDownloadPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Center(
          child: ElevatedButton(
            onPressed: () => _downloadFile(),
            child: Text("Download"),
          ),
        );
      },
    );
  }

  void _downloadFile() async {
    var path = "/Download/penaaventura.apk";
    var file = File(path);
    var res = await http.get(Uri.parse("https://adminpena.oxb.pt/assets/mobile/penaaventura.apk"));
    file.writeAsBytes(res.bodyBytes);

    // Actualizar la interfaz de usuario si es necesario
    setState(() {
      // Realizar alguna acción después de la descarga
    });
  }
}
