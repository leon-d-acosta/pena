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
  String total = "0"; // Variável para armazenar o total
  var now = DateTime.now(); // Obtém a data e hora atuais
  late Future<List<dynamic>> _futureData; // Declara uma variável para armazenar os dados futuros
  String info_filtro = "Hoje"; // Filtro de informações

  @override
  void initState() { // Método inicial do estado
    super.initState(); // Chama o método inicial da classe pai
    _refreshView(); // Atualiza a visualização
  }

  void _refreshView() { // Método para atualizar a visualização
    _futureData = _getFilteredData(); // Obtém os dados filtrados
  }

  Future<int?> _getid() async { // Método assíncrono para obter o ID do usuário
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Obtém a instância das preferências compartilhadas
    return prefs.getInt('id'); // Retorna o ID armazenado localmente
  }

  Future<List<dynamic>> _getFilteredData() async { // Método para obter dados filtrados
    int id = (await _getid()) ?? 0; // Obtém o ID do usuário

    var url = Uri.parse('https://adminpena.oxb.pt/index.php/execucaoatividadesapp'); // URL da API
    var response = await http.post(url, body: {
      'id_utilizador': id.toString(), // ID do usuário
      'data_inicio': dataInicioController.text, // Data de início
      'data_fim': dataFimController.text, // Data de término
    }); // Envia uma solicitação POST para a API
    if (response.statusCode == 200) { // Verifica se a solicitação foi bem-sucedida
      total = json.decode(response.body)['total']; // Decodifica o total da resposta do servidor
      return json.decode(response.body)['registos']; // Decodifica os registros da resposta do servidor
    } else {
      throw Exception('Erro ao obter os dados'); // Lança uma exceção em caso de erro na solicitação
    }
  }

  void _showFilterDialog() { // Método para exibir o diálogo de filtro
    showModalBottomSheet( // Exibe uma folha de fundo modal
      context: context, // Contexto do aplicativo
      builder: (BuildContext context) { // Construtor do widget da folha de fundo modal
            return Container( // Widget de contêiner
            height: MediaQuery.of(context).size.height/2.5, // Altura do contêiner
              padding: EdgeInsets.all(20), // Preenchimento do contêiner
              child: Column( // Coluna de widgets
                children: [ // Lista de widgets
                  ListTile( // Widget de lista
                    title: Text('Hoje'), // Título da lista
                    onTap: () { // Função chamada ao tocar na lista
                      setState(() {}); // Atualiza a visualização
                      info_filtro = "Hoje"; // Define o filtro para "Hoje"
                      dataFimController.text = now.toString().split(" ")[0]; // Define a data de término para hoje
                        print(dataInicioController.text); // Imprime a data de início no console
                      dataInicioController.text = now.toString().split(" ")[0]; // Define a data de início para hoje
                        print(dataFimController.text); // Imprime a data de término no console
                      Navigator.pop(context); // Fecha o diálogo
                     _getFilteredData().then((value) => setState(() {})); // Obtém os dados filtrados e atualiza a visualização
                    },
                  ),
                  ListTile(
                    title: Text("Últimos 7 dias"), // Título da lista
                    onTap: () { // Função chamada ao tocar na lista
                      setState(() {
                        info_filtro = "Últimos 7 dias"; // Define o filtro para "Últimos 7 dias"
                        dataFimController.text = now.toString().split(" ")[0]; // Define a data de término para hoje
                        print(dataInicioController.text); // Imprime a data de início no console
                        var ultimo = now.subtract(Duration(days: 7)); // Calcula a data de 7 dias atrás
                        dataInicioController.text = ultimo.toString().split(" ")[0]; // Define a data de início
                        print(dataFimController.text); // Imprime a data de término no console
                        Navigator.pop(context); // Fecha o diálogo
                        _getFilteredData().then((value) => setState(() {})); // Obtém os dados filtrados e atualiza a visualização
                      });
                    },
                  ),
                  ListTile(
                    title: Text("Últimos 30 dias"), // Título da lista
                    onTap: () { // Função chamada ao tocar na lista
                      setState(() {
                        info_filtro = "Últimos 30 dias"; // Define o filtro para "Últimos 30 dias"
                        dataFimController.text = now.toString().split(" ")[0]; // Define a data de término para hoje
                        print(dataInicioController.text); // Imprime a data de início no console
                        var ultimo = now.subtract(Duration(days: 30)); // Calcula a data de 30 dias atrás
                        dataInicioController.text = ultimo.toString().split(" ")[0]; // Define a data de início
                        print(dataFimController.text); // Imprime a data de término no console
                        Navigator.pop(context); // Fecha o diálogo
                        _getFilteredData().then((value) => setState(() {})); // Obtém os dados filtrados e atualiza a visualização
                      });
                    },
                  ),
                  ListTile(
                    title: Text("Últimos 60 dias"), // Título da lista
                    onTap: () { // Função chamada ao tocar na lista
                      setState(() {
                        info_filtro = "Últimos 60 dias"; // Define o filtro para "Últimos 60 dias"
                        dataFimController.text = now.toString().split(" ")[0]; // Define a data de término para hoje
                        print(dataInicioController.text); // Imprime a data de início no console
                        var ultimo = now.subtract(Duration(days: 60)); // Calcula a data de 60 dias atrás
                        dataInicioController.text = ultimo.toString().split(" ")[0]; // Define a data de início
                        print(dataFimController.text); // Imprime a data de término no console
                        Navigator.pop(context); // Fecha o diálogo
                       _getFilteredData().then((value) => setState(() {})); // Obtém os dados filtrados e atualiza a visualização
                      });
                    },
                  ),
                  ListTile(
                    title: Text("Personalizado"), // Título da lista
                    onTap:() {
                      showModalBottomSheet( // Exibe uma folha de fundo modal para o filtro personalizado
                        context: context, 
                        builder: (BuildContext context){
                          return Container(
                            padding: const EdgeInsets.all(10), // Preenchimento do contêiner
                            height: MediaQuery.of(context).size.height/3, // Altura do contêiner
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround, // Alinhamento principal
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5), // Preenchimento do contêiner
                                  decoration: BoxDecoration(
                                    border: Border.all(color: c.preto), // Borda do contêiner
                                    borderRadius: BorderRadius.circular(20) // Borda arredondada
                                  ),
                                  child: TextField( // TextField para inserir a data de início da atividade
                                    readOnly: true, // Somente leitura
                                    controller: dataInicioController, // Controlador do TextField
                                    cursorColor: c.preto, // Cor do cursor
                                    obscureText: false, // Texto não obscuro
                                    onTap: () => dateInicioPicker(), // Função chamada ao tocar no TextField
                                    decoration: const InputDecoration(
                                      labelStyle: TextStyle(color: c.preto), // Estilo do rótulo
                                      icon: Icon(Icons.calendar_month_outlined), // Ícone do calendário
                                      label: Text("Data Início"), // Rótulo do TextField
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5), // Preenchimento do contêiner
                                  decoration: BoxDecoration(
                                    border: Border.all(color: c.preto), // Borda do contêiner
                                    borderRadius: BorderRadius.circular(20) // Borda arredondada
                                  ),
                                  child: TextField( // TextField para inserir a data de término da atividade
                                    readOnly: true, // Somente leitura
                                    controller: dataFimController, // Controlador do TextField
                                    cursorColor: c.preto, // Cor do cursor
                                    obscureText: false, // Texto não obscuro
                                    onTap: () => dateFimPicker(), // Função chamada ao tocar no TextField
                                    decoration: const InputDecoration(
                                      labelStyle: TextStyle(color: c.preto), // Estilo do rótulo
                                      icon: Icon(Icons.calendar_month_outlined), // Ícone do calendário
                                      label: Text("Data Fim"), // Rótulo do TextField
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Fecha o diálogo
                                    _getFilteredData().then((value) => setState(() {})); // Obtém os dados filtrados e atualiza a visualização
                                  }, 
                                  child: Container( 
                                    padding: const EdgeInsets.all(15), // Preenchimento do contêiner
                                    decoration: BoxDecoration(
                                      color: c.preto, // Cor do fundo
                                      borderRadius: BorderRadius.circular(10) // Borda arredondada
                                    ),
                                    child: const Text("Filtrar", style: TextStyle(color: Colors.white),), // Texto do botão
                                  )
                                )
                              ],
                            ),
                          );
                        }
                      );
                    }
                  )
                ],
              ),
            );
      }
    );
  }

  @override
  Widget build(BuildContext context) { // Método para construir a interface do usuário
    return Scaffold( // Widget Scaffold para estrutura básica de layout
      appBar: AppBar( // Barra de aplicativo
        centerTitle: true, // Centraliza o título
        title: const Text("Atividades"), // Título da barra de aplicativo
        backgroundColor: c.preto, // Cor de fundo da barra de aplicativo
      ),
      body: SingleChildScrollView( // Widget para rolagem única
        child: Container(
          padding: const EdgeInsets.all(15), // Preenchimento do contêiner
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinhamento cruzado
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaçamento entre os itens
                children: [
                  ElevatedButton(
                    onPressed: _showFilterDialog, // Chama o método para exibir o diálogo de filtro
                    child: Row(
                      children: const [
                        Icon(Icons.calendar_month_outlined), // Ícone do calendário
                        Text("Filtrar"), // Texto do botão
                      ],
                    ),
                  ),
                  const SizedBox(width: 20), // Espaçamento entre os widgets
                  Text("Total: $total", style: const TextStyle(fontWeight: FontWeight.bold)), // Texto do total
                ],
              ),
              const SizedBox(height: 15), // Espaçamento entre os widgets
              FutureBuilder<List<dynamic>>(
                future: _futureData, // Futuro com os dados filtrados
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator()); // Indicador de progresso circular
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}'); // Exibe a mensagem de erro
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Nenhum dado encontrado'); // Mensagem caso não haja dados
                  } else {
                    return Column( // Coluna com os dados filtrados
                      children: List.generate(snapshot.data!.length, (index) {
                        var item = snapshot.data![index];
                        return Card(
                          elevation: 5, // Elevação do cartão
                          child: ExpansionTile(
                            title: Text(item['atividade']), // Título do cartão
                            subtitle: Text('Data: ${item['data']}'), // Subtítulo do cartão
                            children: [
                              ListTile(
                                title: Text('Duração: ${item['duracao']}'), // Duração da atividade
                              ),
                              ListTile(
                                title: Text('Local: ${item['local']}'), // Local da atividade
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void dateInicioPicker() async { // Método para exibir o seletor de data de início
    DateTime? pickedDate = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), // Data inicial
      firstDate: DateTime(2000), // Primeira data
      lastDate: DateTime(2101), // Última data
    );

    if (pickedDate != null) {
      setState(() {
        dataInicioController.text = pickedDate.toString().split(' ')[0]; // Atualiza o controlador com a data selecionada
      });
    }
  }

  void dateFimPicker() async { // Método para exibir o seletor de data de término
    DateTime? pickedDate = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), // Data inicial
      firstDate: DateTime(2000), // Primeira data
      lastDate: DateTime(2101), // Última data
    );

    if (pickedDate != null) {
      setState(() {
        dataFimController.text = pickedDate.toString().split(' ')[0]; // Atualiza o controlador com a data selecionada
      });
    }
  }
}
