import 'dart:convert'; // Importa a biblioteca 'dart:convert' para lidar com codificação e decodificação de JSON
import 'package:flutter/material.dart'; // Importa o pacote Flutter Material Design
import 'package:PenaAventura/views/cores/cor.dart'; // Importa as cores do aplicativo
import 'package:shared_preferences/shared_preferences.dart'; // Importa a biblioteca para lidar com preferências compartilhadas
import 'package:http/http.dart' as http; // Importa o pacote HTTP para fazer solicitações HTTP

class InfoPicagem extends StatefulWidget { // Classe para a tela de informações
  const InfoPicagem({super.key}); // Construtor da classe

  @override
  State<InfoPicagem> createState() => _InfoPicagemState(); // Cria um estado para a tela de informações
}

class _InfoPicagemState extends State<InfoPicagem> { // Estado da tela de informações
  TextEditingController dataInicioController = TextEditingController(); // Controlador para a data de início
  TextEditingController dataFimController = TextEditingController(); // Controlador para a data de término
  ValueNotifier<List<bool>> _isExpanded = ValueNotifier<List<bool>>([]); // Lista para controlar a expansão dos painéis
  String total = "0";
  late Future<List<dynamic>> _futureData; // Declara uma variável para armazenar os dados futuros.

  @override
  void initState() {
    super.initState();
    _refreshView();
  }

  void _refreshView() {
    _futureData = _getFilteredData();
  }

  Future<int?> _getid() async { // Método assíncrono para obter o ID do usuário
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Obtém a instância das preferências compartilhadas
    return prefs.getInt('id'); // Retorna o ID armazenado localmente
  }

  Future<List<dynamic>> _getFilteredData() async { // Método para obter dados filtrados
    int id = (await _getid()) ?? 0; // Obtém o ID do usuário

    var url = Uri.parse('https://adminpena.oxb.pt/index.php/execucaoatividadesapp'); // URL da API
    var response = await http.post(url, body: {
      'id_utilizador': id.toString(),
      'data_inicio': dataInicioController.text,
      'data_fim': dataFimController.text,
    }); // Envia uma solicitação POST para a API
    if (response.statusCode == 200) { // Verifica se a solicitação foi bem-sucedida
      total = json.decode(response.body)['total'];
      return json.decode(response.body)['registos']; // Decodifica a resposta do servidor
    } else {
      throw Exception('Erro ao obter os dados'); // Lança uma exceção em caso de erro na solicitação
    }
  }

  void _showFilterDialog() { // Método para exibir o diálogo de filtro
    showModalBottomSheet( // Exibe uma folha de fundo modal
      context: context, // Contexto do aplicativo
      builder: (BuildContext context) { // Construtor do widget da folha de fundo modal
        return FutureBuilder( // Constrói um widget com base em um futuro
          future: _getFilteredData(), // Futuro para construir o widget
          builder: (BuildContext context, AsyncSnapshot snapshot) { // Construtor do widget com base no snapshot do futuro
            if (snapshot.connectionState == ConnectionState.waiting) { // Verifica se a conexão está aguardando
              return const Center(child: CircularProgressIndicator()); // Retorna um indicador de progresso
            }
            if (snapshot.hasError) { // Verifica se há um erro no snapshot
              return Center(child: Text("${snapshot.error}")); // Retorna o erro
            }
            if (snapshot.data.isEmpty) { // Verifica se não há dados no snapshot
              //return const Center(child: Text("Não há informação")); // Retorna uma mensagem de que não há informações
            }

            return Container( // Widget de contêiner
              padding: EdgeInsets.all(20), // Preenchimento do contêiner
              child: Column( // Coluna de widgets
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinhamento principal da coluna
                children: [ // Lista de widgets
                  ListTile( // Widget de lista
                    title: Text('Todos'), // Título da lista
                    onTap: () { // Função chamada ao tocar na lista
                      setState(() {}); // Atualiza a visualização
                      Navigator.pop(context); // Fecha a folha de fundo modal
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: c.preto),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: TextField( //TextField para inserir a data do inicio da atividade
                      readOnly: true,
                      controller: dataInicioController,
                      cursorColor: c.preto,
                      obscureText: false,
                      onTap: () => dateInicioPicker(),
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(color: c.preto),
                        icon: Icon(Icons.calendar_month_outlined),
                        label: Text("Data Início"),
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: c.preto),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: TextField( // TextField para inserir a data do fim da atividade
                      readOnly: true,
                      controller: dataFimController,
                      cursorColor: c.preto,
                      obscureText: false,
                      onTap: () => dateFimPicker(),
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(color: c.preto),
                        icon: Icon(Icons.calendar_month_outlined),
                        label: Text("Data Fim"),
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  GestureDetector( //botão para filtrar com as datas que insiriu o usuario
                    onTap: () {
                      _getFilteredData().then((value) => setState(() {}));
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height/15,
                      decoration: BoxDecoration(
                        color: c.azul_1,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Center(child: Text("Filtrar", style: TextStyle(color: c.branco))),
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
  Widget build(BuildContext context) { // Método para construir a interface do usuário
    return Scaffold( // Retorna um widget de Scaffold
      backgroundColor: c.branco, // Define a cor de fundo do Scaffold
      body: SafeArea( // Corpo seguro do Scaffold
        child: FutureBuilder( // Construtor de widget baseado em futuro
          future: _getFilteredData(), // Futuro para construir o widget
          builder: (BuildContext context, AsyncSnapshot snapshot) { // Construtor de widget com base no snapshot do futuro
            if (snapshot.connectionState == ConnectionState.waiting) { // Verifica se a conexão está aguardando
              return const Center(child: CircularProgressIndicator()); // Retorna um indicador de progresso
            }
            if (snapshot.hasError) { // Verifica se há um erro no snapshot
              return Center(child: Text("${snapshot.error}")); // Retorna o erro
            }
            if (snapshot.data.isEmpty) { // Verifica se não há dados no snapshot
              //return const Center(child: Text("Não há informação")); // Retorna uma mensagem de que não há informações
            }

            List<dynamic> snap = snapshot.data!; // Obtém os dados do snapshot
            if (_isExpanded.value.length != snap.length) { // Verifica o comprimento da lista de expansão
              _isExpanded.value = List<bool>.filled(snap.length, false); // Preenche a lista de expansão com valores falsos
            }

            return SingleChildScrollView( // Retorna um widget de rolagem
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      height: MediaQuery.of(context).size.height/6.5,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: c.azul_2.withOpacity(0.4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total: "),
                          Text("${total}€", style: TextStyle(fontSize: 40)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder(
                      valueListenable: _isExpanded,
                      builder: (context, List<bool> isExpanded, _) {
                        return ExpansionPanelList( // Lista de painéis expansíveis
                          expandedHeaderPadding: const EdgeInsets.all(5), // Preenchimento do cabeçalho expandido
                          animationDuration: Duration(milliseconds: 200), // Duração da animação
                          elevation: 1, // Elevação dos painéis
                          materialGapSize: 5, // Tamanho do espaço entre os painéis
                          children: List.generate(snap.length, (index) { // Gera uma lista de widgets com base nos dados
                            return ExpansionPanel( // Painel expansível
                              backgroundColor: c.branco, // Cor de fundo do painel
                              canTapOnHeader: true, // Permite tocar no cabeçalho do painel
                              isExpanded: isExpanded[index], // Define se o painel está expandido ou não
                              headerBuilder: (context, isExpanded) => Padding( // Construtor de cabeçalho
                                padding: const EdgeInsets.all(5.0), // Preenchimento do cabeçalho
                                child: Column( // Coluna de widgets
                                  crossAxisAlignment: CrossAxisAlignment.start, // Alinhamento cruzado dos widgets
                                  children: [
                                    Row( // Linha de widgets
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinhamento principal dos widgets
                                      children: [
                                        Expanded(
                                          child: Text(
                                            snap[index]['nome_produto'], 
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            maxLines: 2,
                                            textScaler: TextScaler.linear(0.8),
                                            ),
                                        ), // Exibe o nome do item
                                        Text("${snap[index]['quantidade_picada']} Qtd", style: TextStyle(fontWeight: FontWeight.bold),) // Exibe a quantidade picada
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(snap[index]['nome_posto']), // Exibe informações estáticas
                                        Text("${snap[index]['total_parceiro'].toString()}€", style: TextStyle(color: c.azul_1),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              body: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Column( // Corpo do painel
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("Monitor:", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("${snap[index]['nome_monitor']}"),
                                      ],
                                    ), // Exibe dados dinâmicos
                                    Row(
                                      children: [
                                        Text("Monitor:", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("${snap[index]['cliente']}"),
                                      ],
                                    ), // Exibe dados dinâmicos
                                    Row(
                                      children: [
                                        Text("Percentagem: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("${snap[index]['percentagem_parceiro']}%"),
                                      ],
                                    ), // Exibe dados dinâmicos
                                    Row(
                                      children: [
                                        Text("Monitor:", style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text("${snap[index]['data_criacao']}"),
                                      ],
                                    ), // Exibe dados dinâmicos
                                  ],
                                ),
                              ),
                            );
                          }),
                          expansionCallback: (panelIndex, isExpanded) { // Função de retorno de chamada de expansão
                            _isExpanded.value[panelIndex] = isExpanded; // Define o estado de expansão do painel
                            _isExpanded.notifyListeners(); // Notifica os ouvintes sobre a alteração
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton( // Botão flutuante
        backgroundColor: c.azul_1, // Cor de fundo do botão
        onPressed: _showFilterDialog, // Função chamada ao pressionar o botão
        child: Icon(Icons.filter_list, color: c.branco), // Ícone do botão
      ),
    );
  }

  Future<void> dateInicioPicker() async { // Método assíncrono para selecionar a data de início
    DateTime? picked = await showDatePicker( // Exibe um seletor de data
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2040)
    );

    if (picked != null) { // Verifica se a data foi selecionada
      dataInicioController.text = picked.toString().split(" ")[0]; // Define a data selecionada no controlador
    }
  }

  Future<void> dateFimPicker() async { // Método assíncrono para selecionar a data de término
    DateTime? picked = await showDatePicker( // Exibe um seletor de data
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2040)
    );

    if (picked != null) { // Verifica se a data foi selecionada
      dataFimController.text = picked.toString().split(" ")[0]; // Define a data selecionada no controlador
      print(dataFimController.text);
    }
  }
}
