import 'dart:convert'; // Importa a biblioteca para manipulação de dados JSON

import 'package:PenaAventura/views/cores/cor.dart'; // Importa o módulo de cores personalizado
import 'package:PenaAventura/views/login/login.dart'; // Importa a tela de login
import 'package:PenaAventura/views/perfil/updates_perfil/updateApelido.dart'; // Importa a tela para atualizar o apelido
import 'package:PenaAventura/views/perfil/updates_perfil/updateNome.dart'; // Importa a tela para atualizar o nome
import 'package:flutter/material.dart'; // Importa a biblioteca principal do Flutter para construção de UI
import 'package:shared_preferences/shared_preferences.dart'; // Importa a biblioteca para manipulação de preferências compartilhadas
import 'package:http/http.dart' as http; // Importa a biblioteca para fazer requisições HTTP

class Perfil extends StatefulWidget {
  const Perfil({super.key}); // Construtor da classe Perfil

  @override
  State<Perfil> createState() => _PerfilState(); // Cria o estado da tela Perfil
}

class _PerfilState extends State<Perfil> {
  late Future<List<dynamic>> _perfilData; // Declaração de uma variável Future para armazenar os dados do perfil

  @override
  void initState() {
    _refreshView(); // Chama a função para atualizar a visão ao iniciar
    super.initState(); // Chama o initState da classe pai
  }

  void _refreshView() {
    setState(() {
      _perfilData = _getData(); // Chama _getData() para obter os dados atualizados
    });
  }

  void ScaffoldChanger(String field, snap) {
    // Função para navegar para a tela de alteração de nome ou apelido
    WidgetBuilder bottom = (BuildContext context) {
      switch (field) {
        case 'nome':
          return ChangeNomeAlert(nome: snap); // Retorna a tela para alterar o nome
        case 'apelido':
          return ChangeApelido(apelido: snap); // Retorna a tela para alterar o apelido
        default:
          throw Exception('Invalid field: $field'); // Lança uma exceção para campos inválidos
      }
    };

    Navigator.push(context, MaterialPageRoute(builder: bottom)).then((value) {
      _refreshView(); // Chama _refreshView() após fechar a tela de alteração
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Obtém uma instância de SharedPreferences
    await prefs.remove('id'); // Remove o ID do usuário
    await prefs.remove('email'); // Remove o email do usuário
    await prefs.remove('palavra-passe'); // Remove a palavra-passe do usuário

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: ((context) => Login())), // Navega para a tela de login
      (route) => false, // Remove todas as rotas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: c.cinza, // Define a cor de fundo do container
          height: double.infinity, // Define a altura como infinita
          padding: const EdgeInsets.all(20), // Define o padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza o conteúdo verticalmente
            children: [
              Container(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_circle,
                        color: c.azul_1,
                        size: MediaQuery.of(context).orientation == Orientation.portrait ? 100 : 50,
                      ), // Ícone do perfil
                      Text(
                        "M E U     P E R F I L",
                        style: TextStyle(
                          color: c.azul_1,
                          fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 25,
                        ),
                      ), // Texto do título
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10), // Define a margem superior
                height: MediaQuery.of(context).orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height / 4.75
                    : MediaQuery.of(context).size.height / 2.15, // Define a altura conforme a orientação
                child: FutureBuilder(
                  future: _perfilData, // Usa a variável Future _perfilData
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(), // Mostra um indicador de progresso enquanto carrega
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error fetching data"), // Mostra uma mensagem de erro se houver falha
                      );
                    }
                    List snap = snapshot.data; // Obtém os dados do snapshot
                    List<String> fields = ['nome', 'apelido', 'email']; // Campos do perfil
                    return Container(
                      decoration: BoxDecoration(
                        color: c.branco,
                        borderRadius: BorderRadius.circular(10),
                      ), // Decoração do container
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os itens para ocupar o espaço disponível
                        children: List.generate(fields.length, (index) {
                          String field = fields[index]; // Campo atual
                          return GestureDetector(
                            onTap: () {
                              if (field != 'email') {
                                ScaffoldChanger(field, snap[0][field]); // Chama ScaffoldChanger para campos editáveis
                              }
                            },
                            child: ListTile(
                              title: Text(
                                snap[0][field],
                                style: const TextStyle(color: c.preto), // Estilo do texto
                              ),
                              trailing: field != 'email'
                                  ? const Icon(Icons.edit, color: c.cinza_2,)
                                  : const Icon(Icons.alternate_email, color: c.cinza_2,), // Ícone conforme o campo
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 40, // Define a posição superior
          right: 20, // Define a posição à direita
          child: GestureDetector(
            onTap: _logout, // Chama a função de logout ao tocar
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent, // Define a cor de fundo
                borderRadius: BorderRadius.circular(50), // Define os cantos arredondados
              ),
              padding: const EdgeInsets.all(10), // Define o padding
              child: Icon(
                Icons.power_settings_new,
                size: 25,
                color: c.branco, // Cor do ícone
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<dynamic>> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Obtém uma instância de SharedPreferences
    int id = prefs.getInt('id') ?? 0; // Obtém o ID do usuário

    var url = Uri.parse('https://lavandaria.oxb.pt/index.php/get_perfil_app'); // URL da API para obter os dados do perfil
    var response = await http.post(url, body: {'id_utilizador': id.toString()}); // Faz uma requisição POST com o ID do usuário

    if (response.statusCode == 200) {
      return json.decode(response.body); // Decodifica e retorna os dados se a requisição for bem-sucedida
    } else {
      throw Exception('Error al obtener los datos'); // Lança uma exceção se houver erro na requisição
    }
  }
}
