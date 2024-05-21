import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PenaAventura/views/cores/cor.dart';
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
              color: c.cinza, // Replace c.cinza with Colors.grey
              child: Image.network(widget.data['foto'], fit: BoxFit.cover),
            ),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.verde_2, // Replace c.verde_2 with Colors.green[200]
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: c.verde_1, // Replace c.verde_1 with Colors.green[400]
                                borderRadius: BorderRadius.circular(5),
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
                        Text("${_itemCount}"),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _itemCount++;
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
                            setState(() {});
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
                            setState(() {});
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
                      borderRadius: BorderRadius.circular(10),
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
                              Icon(Icons.task_alt_outlined),
                              Text("Atividade realizada"),
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
}