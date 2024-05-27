import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:PenaAventura/views/cores/cor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class InfoPicagem extends StatefulWidget {
  const InfoPicagem({super.key});

  @override
  State<InfoPicagem> createState() => _InfoPicagemState();
}

class _InfoPicagemState extends State<InfoPicagem> {
  late Future<List<dynamic>> _futureData;
  TextEditingController dataInicioController = TextEditingController();
  TextEditingController dataFimController = TextEditingController();
  List<bool> _isExpanded = [];

  @override
  void initState() {
    super.initState();
    _refreshView();
  }

  void _refreshView() {
    setState(() {
      _futureData = _getData();
    });
  }

  Future<int?> _getid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<List<dynamic>> _getFilteredData(dataInicio, dataFim) async {
    int id = (await _getid()) ?? 0;

    var url = Uri.parse('https://adminpena.oxb.pt/index.php/getpostosapp');
    var response = await http.post(url, body: {'id': id.toString()});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos');
    }
  }

  Future<List<dynamic>> _getData() async {
    int id = (await _getid()) ?? 0;

    var url = Uri.parse('https://adminpena.oxb.pt/index.php/getpostosapp');
    var response = await http.post(url, body: {'id': id.toString()});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos');
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _futureData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }
            if (snapshot.data.isEmpty) {
              return const Center(child: Text("Não há informação"));
            }
            //List<dynamic> snap = snapshot.data!;

            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListTile(
                    title: Text('Todos'),
                    onTap: () {
                      _refreshView();
                      Navigator.pop(context);
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: c.preto),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: TextField( // Crea un campo de texto.
                      readOnly: true,
                      controller: dataInicioController, // Asigna el controlador de la contraseña.
                      cursorColor: c.preto, // Establece el color del cursor.
                      obscureText: false, // El texto es oculto.
                      onTap: () => dateInicioPicker(),
                      decoration: const InputDecoration( // Aplica decoraciones al campo de texto.
                        labelStyle: TextStyle(color: c.preto), // Establece el estilo del texto de la etiqueta.
                        icon: Icon(Icons.calendar_month_outlined), // Añade un ícono al campo de texto.
                        label: Text("Data Inicio"), // Añade una etiqueta al campo de texto.
                        border: InputBorder.none, // Sin borde.
                        filled: false, // El campo no está lleno.
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: c.preto),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: TextField( // Crea un campo de texto.
                      readOnly: true,
                      controller: dataFimController, // Asigna el controlador de la contraseña.
                      cursorColor: c.preto, // Establece el color del cursor.
                      obscureText: false, // El texto es oculto.
                      onTap: () => dateFimPicker(),
                      decoration: const InputDecoration( // Aplica decoraciones al campo de texto.
                        labelStyle: TextStyle(color: c.preto), // Establece el estilo del texto de la etiqueta.
                        icon: Icon(Icons.calendar_month_outlined), // Añade un ícono al campo de texto.
                        label: Text("Data Fim"), // Añade una etiqueta al campo de texto.
                        border: InputBorder.none, // Sin borde.
                        filled: false, // El campo no está lleno.
                      ),
                    ),
                  ),
                  GestureDetector(
                    
                    //onTap: () => _getFilteredData(dataInicioController.text, dataFimController.text),
                    child: Container(
                      height: MediaQuery.of(context).size.height/15,
                      decoration: BoxDecoration(
                        color: c.azul_1,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Center(child: Text("Filtrar", style: TextStyle(color: c.branco),),),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.branco,
      body: SafeArea(
        child: FutureBuilder(
          future: _futureData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }
            if (snapshot.data.isEmpty) {
              return const Center(child: Text("Não há informação"));
            }
            List<dynamic> snap = snapshot.data!;
            if (_isExpanded.length != snap.length) {
              _isExpanded = List<bool>.filled(snap.length, false);
            }
            
            return SingleChildScrollView(
              child: ExpansionPanelList(
                expandedHeaderPadding: const EdgeInsets.all(10),
                animationDuration: Duration(milliseconds: 200),
                elevation: 1,
                materialGapSize: 5,
                children: List.generate(snap.length, (index) {
                  return ExpansionPanel(
                    backgroundColor: c.azul_2.withOpacity(0.3),
                    canTapOnHeader: true,
                    isExpanded: _isExpanded[index],
                    headerBuilder: (context, isExpanded) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(snap[index]['nome']),
                              Text("£ valor")
                            ],
                          ),
                          Text("info")
                        ],
                      ),
                    ),
                    body: Column(
                      children: [
                        Text("data 1"),
                        Text("data 2"),
                        Text("data 3"),
                      ],
                    ),
                  );
                }),
                expansionCallback: (panelIndex, isExpanded) {
                  setState(() {
                    _isExpanded[panelIndex] = isExpanded;
                  });
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: c.azul_1,
        onPressed: _showFilterDialog,
        child: Icon(Icons.filter_list, color: c.branco),
      ),
    );
  }
  
  Future<void> dateInicioPicker() async {
    DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime(2022), 
      lastDate: DateTime(2040)
    );

    if(picked != null){
      dataInicioController.text = picked.toString().split(" ")[0];
    };
  }

  Future<void> dateFimPicker() async {
    DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime(2022), 
      lastDate: DateTime(2040)
    );

    if(picked != null){
      dataFimController.text = picked.toString().split(" ")[0];
    };
  }
}
