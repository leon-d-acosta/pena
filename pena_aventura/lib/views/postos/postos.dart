import 'dart:convert'; // Importa a biblioteca 'dart:convert' para manipulação de dados JSON.

import 'package:PenaAventura/views/cores/cor.dart'; // Importa um arquivo local com cores personalizadas.
import 'package:PenaAventura/views/postos/qr_tarefa/qr_scanner.dart'; // Importa o widget do scanner QR.
import 'package:flutter/material.dart'; // Importa o pacote Flutter para construir a interface de usuário.
import 'package:shared_preferences/shared_preferences.dart'; // Importa o pacote para gerenciamento de preferências compartilhadas.
import 'package:http/http.dart' as http; // Importa o pacote HTTP para realizar solicitações web.

class Postos extends StatefulWidget { // Define uma classe de widget com estado chamada 'Postos'.
  const Postos({super.key});

  @override
  State<Postos> createState() => _PostosState(); // Cria um estado para o widget 'Postos'.
}

class _PostosState extends State<Postos> {
  late Future<List<dynamic>> _futureData; // Declara uma variável para armazenar os dados futuros.

  @override
  void initState() {
    super.initState();
    _futureData = _getData(); // Inicializa a variável com os dados obtidos da função '_getData'.
  }

  Future<int?> _getid() async { // Função para obter o ID do usuário das preferências compartilhadas.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id'); // Retorna o ID armazenado nas preferências.
  }

  Future<List<dynamic>> _getData() async { // Função para obter os dados dos postos.
    int id = (await _getid()) ?? 0; // Obtém o ID do usuário, ou 0 se não estiver disponível.

    var url = Uri.parse('https://adminpena.oxb.pt/index.php/getpostosapp'); // Define a URL da solicitação.
    var response = await http.post(url, body: {'id': id.toString()}); // Realiza a solicitação POST com o ID do usuário.

    if (response.statusCode == 200) { // Verifica se a solicitação foi bem-sucedida.
      return json.decode(response.body); // Decodifica os dados JSON da resposta.
    } else {
      throw Exception('Erro ao obter os dados'); // Lança uma exceção se houver um erro na solicitação.
    }
  }

  @override
  Widget build(BuildContext context) { // Define o método de construção do widget.
    return Scaffold(
      backgroundColor: c.branco, // Define a cor de fundo da tela.
      body: Padding(
        padding: const EdgeInsets.all(10), // Define o preenchimento ao redor do corpo.
        child: FutureBuilder(
          future: _futureData, // Define o futuro a ser observado.
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) { // Verifica se os dados estão sendo carregados.
              return const Center(child: CircularProgressIndicator()); // Mostra um indicador de progresso enquanto os dados são carregados.
            }
            if (snapshot.hasError) { // Verifica se houve um erro ao carregar os dados.
              return Center(child: Text("${snapshot.error}")); // Mostra a mensagem de erro.
            }
            List<dynamic> snap = snapshot.data; // Armazena os dados carregados.
            return GridView.builder(
              itemCount: snap.length, // Define o número de itens na grade.
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4, // Define o número de colunas baseado na orientação da tela.
                mainAxisSpacing: 15, // Define o espaçamento principal entre os itens.
                crossAxisSpacing: 15 // Define o espaçamento cruzado entre os itens.
              ), 
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Qr_Scanner(id_posto: snap[index]['id']))), // Navega para a página de escaneamento QR ao tocar no item.
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), // Define os cantos arredondados do contêiner.
                      color: c.cinza_2, // Define a cor de fundo do contêiner.
                    ),
                    width: MediaQuery.of(context).orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.5 - 15 
                        : MediaQuery.of(context).size.width * 0.25 - 15, // Define a largura do contêiner baseado na orientação da tela.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // Alinha os itens ao centro horizontalmente.
                      children: [
                        Container(height: MediaQuery.of(context).size.height/6, child: ClipRRect(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)), child: Image.network(snap[index]['foto'], fit: BoxFit.cover))), // Exibe a imagem do posto com cantos arredondados.
                        Container(margin: const EdgeInsets.only(left: 20, right: 20), child: Center(child: Text(snap[index]['nome'], style: TextStyle(color: c.branco, fontSize: 15)))), // Exibe o nome do posto.
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
