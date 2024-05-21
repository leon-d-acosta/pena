import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PenaAventura/views/cores/cor.dart'; // Asegúrate de que esta importación sea correcta
import 'package:http/http.dart' as http;

class SearchTarefa extends StatefulWidget {
  final String id_posto;
  final String qr;

  const SearchTarefa({Key? key, required this.id_posto, required this.qr}) : super(key: key);

  @override
  State<SearchTarefa> createState() => _SearchTarefaState();
}

class _SearchTarefaState extends State<SearchTarefa> {
  Future<List<dynamic>>? _dataFuture;
  int verificador = 0;

  @override
  void initState() {
    super.initState();
    _dataFuture = _getData();
  }

  Future<int?> _getid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<List<dynamic>> _getData() async {
    int id = (await _getid()) ?? 0;
    
    var url = Uri.parse('https://adminpena.oxb.pt/index.php/getatividadesapp');
    var response = await http.post(url, body: {'id': id.toString(), 'id_posto': widget.id_posto, 'qrcode': widget.qr});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.cinza,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: FutureBuilder<List<dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data!.isEmpty) {
              // Mostrar diálogo si los datos están vacíos
              if (verificador == 0) {
                Future.delayed(Duration.zero, () => _showDialog(context));
                verificador = 1;
              }
              return Center(child: Text('No se encontraron datos.'));
            } else {
              List<dynamic>? data = snapshot.data;
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: data!.length,
                itemBuilder: (context, index) {
                  return ListTileItem(
                    data: data[index],
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        foregroundColor: c.branco,
        backgroundColor: c.azul_1,
        elevation: 10,
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("QR incorrecto"),
          content: Text("O QR code que tentou escanear não pertenece ao posto desejado"),
          actions: <Widget>[
            TextButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
}

class ListTileItem extends StatefulWidget {
  final dynamic data;

  const ListTileItem({required this.data});

  @override
  _ListTileItemState createState() => _ListTileItemState();
}

class _ListTileItemState extends State<ListTileItem> {
  int _itemCount = 0;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      subtitle: Column(
        children: [
          if (widget.data['foto'].isNotEmpty)
            Container(
              height: MediaQuery.of(context).size.height / 3,
              width: double.infinity,
              color: c.cinza, // Replace c.cinza with Colors.grey if necessary
              child: Image.network(widget.data['foto'], fit: BoxFit.cover),
            ),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.data['nome_produto'], style: TextStyle(color: c.preto, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(widget.data['nome_produto_principal'], style: TextStyle(color: c.preto, fontSize: 15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text("Data", style: TextStyle(color: c.laranja, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(widget.data['data_atividade'], style: TextStyle(color: c.preto, fontSize: 15)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.data['nome_sessao'], style: TextStyle(color: c.laranja, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("${widget.data['hora']}H", style: TextStyle(color: c.preto, fontSize: 15)),
                      ],
                    ),
                    /*GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.verde_2, // Replace c.verde_2 with Colors.green[200] if necessary
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: c.verde_1, // Replace c.verde_1 with Colors.green[400] if necessary
                                borderRadius: BorderRadius.circular(5),
                              ),
                              height: MediaQuery.of(context).size.height / 15,
                              width: MediaQuery.of(context).size.height / 15,
                              child: Icon(Icons.bolt, color: c.branco),
                            )
                          ],
                        ),
                      ),
                    ),*/
                  ],
                ),
                Divider(color: c.preto.withOpacity(0.2), height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text("Compradas: ${widget.data['quantidade']}", style: TextStyle(fontSize: 15, color: c.preto)),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text("Concluidas: ${widget.data['utilizada']}", style: TextStyle(fontSize: 15, color: c.preto)),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text("Anuladas: ${widget.data['anuladas']}", style: TextStyle(fontSize: 15, color: c.preto)),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text("Não concluidas: ${widget.data['nao_concluidas']}", style: TextStyle(fontSize: 15, color: c.preto)),
                        ),
                      ],
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.data['nao_concluidas'] > 0,
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
                        GestureDetector(
                          onTap: () {
                            if (_itemCount > 0) {
                              setState(() {
                                _itemCount--;
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
                        Text("$_itemCount"),
                        GestureDetector(
                          onTap: () {
                            if (widget.data['nao_concluidas'] > _itemCount) {
                              setState(() {
                                _itemCount++;
                              });
                            }
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
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.data['nao_concluidas'] > 0,
                  child: Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_itemCount > 0) _showDialogAnular(context, widget.data, _itemCount);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: c.laranja,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            width: MediaQuery.of(context).size.width / 2.5,
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
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if(_itemCount > 0) registar(widget.data, _itemCount);
                            },
                          child: Container(
                            decoration: BoxDecoration(
                              color: c.azul_1,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            width: MediaQuery.of(context).size.width / 2.5,
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.data['nao_concluidas'] <= 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: c.verde_1,
                          ),
                          height: MediaQuery.of(context).size.height / 15,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.task_alt_outlined, color: c.branco),
                              Text("Atividade realizada", style: TextStyle(color: c.branco)),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: c.verde_2,
                          ),
                          height: MediaQuery.of(context).size.height / 15,
                          child: Center(
                            child: Text("Processo concluido", style: TextStyle(color: c.branco)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: c.preto.withOpacity(0.2), height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }

  registar(data, item_count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt('id') ?? 0;
    var url = Uri.parse('https://adminpena.oxb.pt/index.php/confirmarquantidadeapp');
    var response = await http.post(url, body: {
      'id_utilizador': id.toString(),
      'id_venda_cab': data['id_venda_cab'],
      'id_venda_lin': data['id_venda_lin'],
      'id_venda_artigo': data['id_venda_artigo'],
      'id_mov_sessao_gestao': data['id'],
      'quantidade': item_count.toString(),
      'saldo': item_count.toString(),
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      var decodedData;
      try {
        decodedData = json.decode(response.body); // Intenta decodificar la respuesta JSON.
      } catch (e) {
        print('Error al decodificar la respuesta del servidor: $e'); // Imprime un mensaje de error si falla la decodificación.
      }
      if (decodedData != null && decodedData['status'] != null) { // Verifica si los datos decodificados y el estado no son nulos.
        if (decodedData['status'] == 'success' || decodedData['status'] == true) { // Verifica si el estado es 'success'.
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar( // Muestra un mensaje de error si el inicio de sesión falla.
            content: Center(child: Text(decodedData['status_message'] ?? 'Error desconocido', style: TextStyle(color: c.branco, fontWeight: FontWeight.bold))),
            backgroundColor: Color.fromARGB(255, 216, 59, 48),
          ));
        }
      }
    } else {
      throw Exception('Error al obtener los datos');
    }
  }

  anular(data, itemCount) async {
  
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt('id') ?? 0;
    var url = Uri.parse('https://adminpena.oxb.pt/index.php/anularquantidadeapp');
    var response = await http.post(url, body: {
      'id_utilizador': id.toString(),
      'id_venda_cab': data['id_venda_cab'],
      'id_venda_lin': data['id_venda_lin'],
      'id_venda_artigo': data['id_venda_artigo'],
      'id_mov_sessao_gestao': data['id'],
      'quantidade': itemCount.toString(),
      'saldo': itemCount.toString(),
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      var decodedData;
      try {
        decodedData = json.decode(response.body); // Intenta decodificar la respuesta JSON.
      } catch (e) {
        print('Error al decodificar la respuesta del servidor: $e'); // Imprime un mensaje de error si falla la decodificación.
      }
      if (decodedData != null && decodedData['status'] != null) { // Verifica si los datos decodificados y el estado no son nulos.
        if (decodedData['status'] == 'success' || decodedData['status'] == true) { // Verifica si el estado es 'success'.
          Navigator.pop(context);
          Navigator.pop(context);
          
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar( // Muestra un mensaje de error si el inicio de sesión falla.
            content: Center(child: Text(decodedData['status_message'] ?? 'Error desconocido', style: TextStyle(color: c.branco, fontWeight: FontWeight.bold))),
            backgroundColor: Color.fromARGB(255, 216, 59, 48),
          ));
        }
      }
    } else {
      throw Exception('Error al obtener los datos');
    }
  }

  Future<void> _showDialogAnular(BuildContext context, data, item_count) async {
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Anular atividade"),
          content: Text("Tem a certeza que deseja anular esta atividade?"),
          actions: <Widget>[
            TextButton(
              onPressed: ()=>anular(data, item_count), 
              child: Text("Anular"),
            ),
            TextButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
