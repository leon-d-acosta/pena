import 'dart:convert'; // Importa a biblioteca para conversão de dados JSON.
import 'package:flutter/material.dart'; // Importa o pacote principal do Flutter.
import 'package:PenaAventura/views/cores/cor.dart'; // Importa um arquivo específico para cores do aplicativo.
import 'package:shared_preferences/shared_preferences.dart'; // Importa a biblioteca para manipulação de preferências compartilhadas.
import 'package:table_calendar/table_calendar.dart'; // Importa o pacote do calendário.
import 'package:http/http.dart' as http; // Importa a biblioteca HTTP para fazer solicitações web.

class Calendario extends StatefulWidget { // Define um widget stateful para o calendário.
  const Calendario({super.key}); // Construtor da classe Calendario.

  @override
  State<Calendario> createState() => _CalendarioState(); // Cria o estado do widget.
}

class _CalendarioState extends State<Calendario> { // Define o estado para o widget Calendario.
  CalendarFormat _calendarFormat = CalendarFormat.month; // Define o formato do calendário como mensal.
  DateTime _focusedDay = DateTime.now(); // Define o dia focado como o dia atual.
  DateTime? _selectedDay; // Variável para armazenar o dia selecionado.
  ValueNotifier<List<bool>> _formatChanger = ValueNotifier<List<bool>>([]); // Notificador para mudanças de formato.
  late Future<List<dynamic>> _futureData; // Declaração de uma variável para armazenar dados futuros.
  Map<DateTime, List<String>> _events = {}; // Mapa para armazenar eventos por data.

  @override
  void initState() { // Método que é chamado quando o estado é criado.
    super.initState(); // Chama o método initState da superclasse.
    _refreshView(); // Chama o método para atualizar a visão.
  }

  void _refreshView() { // Método para atualizar a visão.
    _futureData = _getFilteredData(); // Atribui a chamada do método para obter dados filtrados.
  }

  Future<int?> _getid() async { // Método assíncrono para obter o ID do usuário.
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Obtém as preferências compartilhadas.
    return prefs.getInt('id'); // Retorna o ID do usuário das preferências.
  }

  Future<List<dynamic>> _getFilteredData() async { // Método assíncrono para obter dados filtrados.
    int id = (await _getid()) ?? 0; // Obtém o ID do usuário, ou 0 se for nulo.
    var url = Uri.parse('https://adminpena.oxb.pt/index.php/execucaoatividadesapp'); // Define a URL da API.
    var response = await http.post(url, body: { // Faz uma solicitação POST para a API.
      'id_utilizador': id.toString(), // Passa o ID do usuário como parâmetro.
      'data_inicio': "2024-05-14", // Define a data de início.
      'data_fim': "2024-07-30" // Define a data de fim.
    });

    if (response.statusCode == 200) { // Verifica se a resposta foi bem-sucedida.
      List<dynamic> data = json.decode(response.body)['registos']; // Decodifica a resposta JSON.
      print(data); // Imprime os dados para depuração.
      _events.clear(); // Limpa os eventos existentes.
      for (var item in data) { // Itera sobre os dados recebidos.
        DateTime eventDate = DateTime.parse(item['data_criacao']); // Obtém a data do evento.
        if (_events[eventDate] == null) { // Verifica se a data não está no mapa.
          _events[eventDate] = []; // Inicializa a lista para essa data.
        }
        String nome = item['nome_produto'] ?? 'No Name'; // Define o nome do evento, ou um valor padrão.
        _events[eventDate]!.add(nome); // Adiciona o nome do evento à lista.
      }
      return data; // Retorna os dados.
    } else {
      throw Exception('Erro ao obter os dados'); // Lança uma exceção em caso de erro.
    }
  }

  List<String> _getEventsForDay(DateTime day) { // Método para obter eventos de um dia específico.
    return _events[day] ?? []; // Retorna a lista de eventos ou uma lista vazia.
  }

  @override
  Widget build(BuildContext context) { // Método para construir a interface do widget.
    return Scaffold( // Cria um Scaffold para a estrutura básica da tela.
      backgroundColor: c.branco, // Define a cor de fundo.
      body: SafeArea( // Garante que a área de trabalho esteja segura.
        child: FutureBuilder( // Constrói o widget com base em um futuro.
          future: _futureData, // Define o futuro como os dados filtrados.
          builder: (BuildContext context, AsyncSnapshot snapshot) { // Construtor para o snapshot.
            if (snapshot.connectionState == ConnectionState.waiting) { // Verifica se ainda está carregando.
              return Center(child: CircularProgressIndicator()); // Exibe um indicador de carregamento.
            }
            if (snapshot.hasError) { // Verifica se houve um erro.
              print(snapshot.data); // Imprime os dados para depuração.
              return Center(child: Text("Error ${snapshot.error}")); // Exibe uma mensagem de erro.
            }
            List snap = snapshot.data; // Obtém os dados do snapshot.
            return SingleChildScrollView( // Permite rolagem na tela.
              child: Column( // Cria uma coluna de widgets.
                children: [
                  TableCalendar( // Cria o calendário.
                    locale: 'pt_PT', // Define o idioma.
                    firstDay: DateTime.utc(2022, 1, 1), // Define o primeiro dia do calendário.
                    lastDay: DateTime.utc(2030, 1, 1), // Define o último dia do calendário.
                    focusedDay: _focusedDay, // Define o dia focado.
                    selectedDayPredicate: (day) { // Verifica se o dia é o selecionado.
                      return isSameDay(_selectedDay, day); // Compara os dias.
                    },
                    onDaySelected: (selectedDay, focusedDay) { // Método chamado ao selecionar um dia.
                      setState(() { // Atualiza o estado.
                        _selectedDay = selectedDay; // Define o dia selecionado.
                        _focusedDay = focusedDay; // Define o dia focado.
                      });
                    },
                    calendarFormat: _calendarFormat, // Define o formato do calendário.
                    onFormatChanged: (format) { // Método chamado ao mudar o formato.
                      setState(() { // Atualiza o estado.
                        _calendarFormat = format; // Define o novo formato.
                      });
                    },
                    eventLoader: _getEventsForDay, // Define o método para carregar eventos.
                  ),
                  Padding( // Adiciona preenchimento ao contêiner.
                    padding: const EdgeInsets.all(10.0), // Define o preenchimento.
                    child: Container( // Cria um contêiner.
                      width: MediaQuery.of(context).size.width, // Define a largura como a largura da tela.
                      height: _calendarFormat == CalendarFormat.twoWeeks
                          ? MediaQuery.of(context).size.height / 1.75
                          : _calendarFormat == CalendarFormat.month
                              ? MediaQuery.of(context).size.height / 2.75
                              : _calendarFormat == CalendarFormat.week
                                  ? MediaQuery.of(context).size.height / 1.5
                                  : null, // Ajusta a altura com base no formato do calendário.
                      decoration: BoxDecoration( // Adiciona decoração ao contêiner.
                          color: c.azul_2.withOpacity(0.4), // Define a cor de fundo.
                          borderRadius: BorderRadius.circular(30)), // Define os cantos arredondados.
                      child: Padding( // Adiciona preenchimento interno.
                        padding: const EdgeInsets.all(10.0), // Define o preenchimento.
                        child: ListView.builder( // Cria uma lista de itens rolável.
                          itemCount: snap.length, // Define o número de itens na lista.
                          itemBuilder: (context, index) => Padding( // Constrói cada item da lista.
                            padding: const EdgeInsets.all(8.0), // Define o preenchimento dos itens.
                            child: Container( // Cria um contêiner para cada item.
                              padding: const EdgeInsets.all(10), // Define o preenchimento interno.
                              decoration: BoxDecoration( // Adiciona decoração ao contêiner.
                                  borderRadius: BorderRadius.circular(15), // Define os cantos arredondados.
                                  border: Border.all(width: 1)), // Adiciona uma borda ao contêiner.
                              child: Text(
                                "${snap[index]['nome_produto'] ?? 'No Name'}", // Exibe o nome do produto ou um valor padrão.
                                style: TextStyle(fontSize: 18), // Define o estilo do texto.
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
