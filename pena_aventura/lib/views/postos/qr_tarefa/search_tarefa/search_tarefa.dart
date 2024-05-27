import 'package:flutter/material.dart'; // Importa o pacote Flutter para criar interfaces de usuário
import 'dart:convert'; // Importa o pacote 'dart:convert' para codificar e decodificar dados JSON
import 'package:shared_preferences/shared_preferences.dart'; // Importa o pacote shared_preferences para armazenar dados locais
import 'package:PenaAventura/views/cores/cor.dart'; // Importa o pacote que contém as cores utilizadas na aplicação
import 'package:http/http.dart' as http; // Importa o pacote 'http' para fazer requisições HTTP

class SearchTarefa extends StatefulWidget { // Classe StatefulWidget para criar a tela de busca de tarefas
  final String id_posto; // ID do posto
  final String qr; // QR code

  const SearchTarefa({Key? key, required this.id_posto, required this.qr}) : super(key: key); // Construtor da classe

  @override
  State<SearchTarefa> createState() => _SearchTarefaState(); // Cria o estado da tela de busca de tarefas
}

class _SearchTarefaState extends State<SearchTarefa> { // Classe que define o estado da tela de busca de tarefas
  Future<List<dynamic>>? _dataFuture; // Futuro para armazenar os dados da busca
  int verificador = 0; // Variável para verificar se o diálogo já foi mostrado

  @override
  void initState() { // Método chamado quando o estado é inicializado
    super.initState(); // Chama o método initState da classe pai
    _dataFuture = _getData(); // Inicializa o futuro com os dados da busca
  }

  Future<int?> _getid() async { // Função assíncrona para obter o ID do usuário
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Obtém uma instância do SharedPreferences
    return prefs.getInt('id'); // Retorna o ID do usuário
  }

  Future<List<dynamic>> _getData() async { // Função assíncrona para obter os dados da busca
    int id = (await _getid()) ?? 0; // Obtém o ID do usuário ou define como 0 se for nulo
    
    var url = Uri.parse('https://adminpena.oxb.pt/index.php/getatividadesapp'); // URL da API para obter atividades
    var response = await http.post(url, body: {'id': id.toString(), 'id_posto': widget.id_posto, 'qrcode': widget.qr}); // Faz uma requisição POST para obter os dados

    if (response.statusCode == 200) { // Se a requisição for bem-sucedida
      return json.decode(response.body); // Retorna os dados decodificados do corpo da resposta
    } else { // Se a requisição falhar
      throw Exception('Erro ao obter os dados'); // Lança uma exceção informando o erro
    }
  }

  @override
  Widget build(BuildContext context) { // Método responsável por construir a interface da tela
    return Scaffold( // Retorna um Scaffold, que é uma estrutura básica de tela
      backgroundColor: c.branco, // Define a cor de fundo como branco
      body: Container( // Container para organizar o layout da tela
        height: MediaQuery.of(context).size.height, // Define a altura do container como a altura da tela
        width: MediaQuery.of(context).size.width, // Define a largura do container como a largura da tela
        padding: EdgeInsets.zero, // Define o preenchimento do container como zero
        margin: EdgeInsets.zero, // Define a margem do container como zero
        child: FutureBuilder<List<dynamic>>( // Constrói um widget futuro para exibir os dados obtidos
          future: _dataFuture, // Define o futuro como os dados da busca
          builder: (context, snapshot) { // Função para construir o widget com base no estado futuro
            if (snapshot.connectionState == ConnectionState.waiting) { // Se a conexão estiver esperando
              return Center(child: CircularProgressIndicator()); // Retorna um indicador de progresso centralizado
            } else if (snapshot.hasError) { // Se houver um erro
              return Center(child: Text('Erro: ${snapshot.error}')); // Retorna o erro
            } else if (snapshot.data!.isEmpty) { // Se não houver dados na resposta
              // Mostra o diálogo se os dados estiverem vazios
              if (verificador == 0) { // Se o diálogo ainda não foi mostrado
                Future.delayed(Duration.zero, () => _showDialog(context)); // Mostra o diálogo
                verificador = 1; // Define o verificador como 1 para indicar que o diálogo foi mostrado
              }
              return Center(child: Text('Nenhum dado encontrado.')); // Retorna uma mensagem indicando que nenhum dado foi encontrado
            } else { // Se houver dados na resposta
              List<dynamic>? data = snapshot.data; // Obtém os dados da resposta
              return ListView.builder( // Constrói uma lista com os dados obtidos
                padding: EdgeInsets.zero, // Define o preenchimento da lista como zero
                itemCount: data!.length, // Define a quantidade de itens da lista como o tamanho dos dados
                itemBuilder: (context, index) { // Constrói cada item da lista
                  return ListTileItem( // Retorna um item da lista
                    data: data[index], // Passa os dados para o item da lista
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton:      FloatingActionButton( // Botão de ação flutuante
        onPressed: () => Navigator.pop(context), // Função chamada quando o botão é pressionado, que fecha a tela atual
        foregroundColor: c.branco, // Define a cor do ícone do botão como branco
        backgroundColor: c.azul_1, // Define a cor de fundo do botão como azul
        elevation: 10, // Define a elevação do botão como 10
        child: const Icon(Icons.arrow_back), // Ícone do botão para voltar
      ),
    );
  }

  Future<void> _showDialog(BuildContext context) async { // Função para mostrar o diálogo de QR incorreto
    return showDialog<void>( // Mostra um diálogo
      context: context, // Contexto do diálogo
      builder: (BuildContext context) { // Construtor do diálogo
        return AlertDialog( // Retorna um diálogo de alerta
          title: Text("QR incorreto"), // Título do diálogo
          content: Text("O código QR que tentou escanear não pertence ao posto desejado"), // Conteúdo do diálogo
          actions: <Widget>[ // Ações do diálogo
            TextButton( // Botão de texto
              onPressed: () { // Função chamada quando o botão é pressionado
                Navigator.of(context).pop(); // Fecha o diálogo atual
                Navigator.of(context).pop(); // Fecha a tela atual
              },
              child: Text("Fechar"), // Texto do botão
            ),
          ],
        );
      },
    );
  }
  
}

class ListTileItem extends StatefulWidget { // Classe StatefulWidget para construir um item da lista
  final dynamic data; // Dados do item da lista

  const ListTileItem({required this.data}); // Construtor da classe

  @override
  _ListTileItemState createState() => _ListTileItemState(); // Cria o estado do item da lista
}

class _ListTileItemState extends State<ListTileItem> { // Classe que define o estado do item da lista
  int _itemCount = 0; // Contador de itens

  @override
  Widget build(BuildContext context) { // Método responsável por construir a interface do item da lista
    return ListTile( // Retorna um item de lista
      contentPadding: EdgeInsets.zero, // Define o preenchimento do conteúdo do item como zero
      subtitle: Column( // Subtítulo do item como uma coluna
        children: [ // Lista de elementos filhos da coluna
          if (widget.data['foto'].isNotEmpty) // Se houver uma foto
            Container( // Container para a foto
              height: MediaQuery.of(context).size.height / 4.75, // Altura da foto
              width: double.infinity, // Largura da foto
              color: c.cinza, // Cor de fundo da foto
              child: Image.network(widget.data['foto'], fit: BoxFit.cover), // Exibe a foto
            ),
          Container( // Container para os detalhes do item
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10), // Preenchimento do container
            child: Column( // Coluna para os detalhes do item
              crossAxisAlignment: CrossAxisAlignment.center, // Alinhamento dos elementos na coluna
              children: [ // Lista de elementos filhos da coluna
                Text(widget.data['nome_produto'], style: TextStyle(color: c.preto, fontWeight: FontWeight.bold, fontSize: 18)), // Nome do produto
                Text(widget.data['nome_produto_principal'], style: TextStyle(color: c.preto, fontSize: 15)), // Nome principal do produto
                                // Mais elementos omitidos por simplicidade
                
                // Final do conteúdo do item da lista
              ],
            ),
          ),
        ],
      ),
    );
  }

  registar(data, item_count) async { // Função para registrar a atividade
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Obtém uma instância de SharedPreferences
    int id = prefs.getInt('id') ?? 0; // Obtém o ID do usuário dos SharedPreferences
    var url = Uri.parse('https://adminpena.oxb.pt/index.php/confirmarquantidadeapp'); // URL da API para confirmar a quantidade
    var response = await http.post(url, body: { // Faz uma solicitação POST para a API
      'id_utilizador': id.toString(), // ID do usuário
      'id_venda_cab': data['id_venda_cab'], // ID da venda (cabeçalho)
      'id_venda_lin': data['id_venda_lin'], // ID da venda (linha)
      'id_venda_artigo': data['id_venda_artigo'], // ID do artigo da venda
      'id_mov_sessao_gestao': data['id'], // ID do movimento da sessão de gestão
      'quantidade': item_count.toString(), // Quantidade a ser registrada
      'saldo': item_count.toString(), // Saldo da quantidade
    });
    print(response.statusCode); // Imprime o código de status da resposta HTTP
    if (response.statusCode == 200) { // Se a solicitação for bem-sucedida
      var decodedData; // Variável para armazenar os dados decodificados da resposta
      try { // Tenta decodificar a resposta JSON
        decodedData = json.decode(response.body);
      } catch (e) { // Se ocorrer um erro ao decodificar
        print('Error al decodificar la respuesta del servidor: $e'); // Imprime uma mensagem de erro
      }
      if (decodedData != null && decodedData['status'] != null) { // Verifica se os dados decodificados e o status não são nulos
        if (decodedData['status'] == 'success' || decodedData['status'] == true) { // Se o status for 'success'
          Navigator.pop(context); // Fecha a tela atual
        } else { // Se houver um erro
          ScaffoldMessenger.of(context).showSnackBar(SnackBar( // Exibe uma mensagem de erro
            content: Center(child: Text(decodedData['status_message'] ?? 'Erro desconhecido', style: TextStyle(color: c.branco, fontWeight: FontWeight.bold))),
            backgroundColor: Color.fromARGB(255, 216, 59, 48),
          ));
        }
      }
    } else { // Se a solicitação não for bem-sucedida
      throw Exception('Error al obtener los datos'); // Lança uma exceção
    }
  }

  anular(data, itemCount) async { // Função para anular a atividade
    // O mesmo que a função de registro, com algumas modificações
  }

  Future<void> _showDialogAnular(BuildContext context, data, item_count) async { // Função para exibir o diálogo de anulação
    // O mesmo que a função _showDialog, com algumas modificações
  }
}


