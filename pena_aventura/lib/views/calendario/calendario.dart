import 'dart:convert'; // Importa a biblioteca para conversão de dados JSON.
import 'package:flutter/material.dart'; // Importa o pacote principal do Flutter.
import 'package:PenaAventura/views/cores/cor.dart'; // Importa um arquivo específico para cores do aplicativo.
import 'package:shared_preferences/shared_preferences.dart'; // Importa a biblioteca para manipulação de preferências compartilhadas.
import 'package:table_calendar/table_calendar.dart'; // Importa o pacote do calendário.
import 'package:http/http.dart' as http; // Importa a biblioteca HTTP para fazer solicitações web.

class Calendario extends StatefulWidget { // Define um widget stateful para o calendário.
  const Calendario({Key? key}) : super(key: key); // Construtor da classe Calendario.

  @override
  State<Calendario> createState() => _CalendarioState(); // Cria o estado do widget.
}

class Event { // Define uma classe para representar um evento.
  final String title; // Título do evento.

  Event({required this.title}); // Construtor da classe Event.

  @override
  String toString() => title; // Adiciona uma representação em string para depuração.
}

class _CalendarioState extends State<Calendario> { // Define o estado para o widget Calendario.
  late Future<List<dynamic>> _futureData; // Declaração de uma variável para armazenar dados futuros.
  CalendarFormat _calendarFormat = CalendarFormat.month; // Define o formato do calendário como mensal.
  DateTime _focusedDay = DateTime.now(); // Define o dia focado como o dia atual.
  DateTime? _selectedDay; // Variável para armazenar o dia selecionado.
  Map<DateTime, List<Event>> _events = {}; // Mapa para armazenar eventos por data.
  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() { // Método que é chamado quando o estado é criado.
    super.initState(); // Chama o método initState da superclasse.
    _refreshView(); // Chama o método para atualizar a visão.
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
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
      'data_inicio': "2024-02-10", // Define a data de início.
      'data_fim': "2024-10-30" // Define a data de fim.
    });

    if (response.statusCode == 200) { // Verifica se a resposta foi bem-sucedida.
      List<dynamic> data = json.decode(response.body)['registos']; // Decodifica a resposta JSON.
      _events.clear(); // Limpa os eventos existentes.
      for (var item in data) { // Itera sobre os dados recebidos.
        DateTime eventDate = DateTime.parse(item['data_criacao']); // Obtém a data do evento.
        eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day); // Normaliza a data para ignorar tempo.
        if (_events[eventDate] == null) { // Verifica se a data não está no mapa.
          _events[eventDate] = []; // Inicializa a lista para essa data.
        }
        String nome = item['nome_produto'] ?? 'No Name'; // Define o nome do evento, ou um valor padrão.
        _events[eventDate]!.add(Event(title: nome)); // Adiciona o nome do evento à lista.
      }
      return data; // Retorna os dados.
    } else {
      throw Exception('Erro ao obter os dados'); // Lança uma exceção em caso de erro.
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) { // Método chamado quando um dia é selecionado.
    if (!isSameDay(_selectedDay, selectedDay)) { // Verifica se o dia selecionado é diferente do dia selecionado anteriormente.
      setState(() { // Atualiza o estado.
        _selectedDay = selectedDay; // Define o dia selecionado.
        _focusedDay = focusedDay; // Define o dia focado.
        _selectedEvents.value = _getEventsForDay(selectedDay); // Atualiza os eventos selecionados.
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) { // Método para obter eventos de um dia específico.
  List<Event> eventsForSelectedDay = [];
  _events.forEach((key, value) {
    if (key.year == day.year && key.month == day.month && key.day == day.day) {
      eventsForSelectedDay.addAll(value);
    }
  });
  return eventsForSelectedDay; // Retorna os eventos para o dia selecionado.
}

  @override
  Widget build(BuildContext context) { // Método para construir a interface do widget.
    return Scaffold( // Cria um Scaffold para a estrutura básica da tela.
      backgroundColor: c.cinza, // Define a cor de fundo.
      body: SafeArea( // Garante que a área de trabalho esteja segura.
        child: FutureBuilder( // Constrói o widget com base em um futuro.
          future: _futureData, // Define o futuro como os dados filtrados.
          builder: (BuildContext context, AsyncSnapshot snapshot) { // Construtor para o snapshot.
            if (snapshot.connectionState == ConnectionState.waiting) { // Verifica se ainda está carregando.
              return Center(child: CircularProgressIndicator()); // Exibe um indicador de carregamento.
            }
            if (snapshot.hasError) { // Verifica se houve um erro.
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
                    onDaySelected: _onDaySelected,
                    calendarFormat: _calendarFormat, // Define o formato do calendário.
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: c.azul_1),
                      weekendStyle: TextStyle(color: Colors.red)
                    ),
                    onFormatChanged: (format) { // Método chamado ao mudar o formato.
                      setState(() { // Atualiza o estado.
                        _calendarFormat = format; // Define o novo formato.
                      });
                    },
                    eventLoader: _getEventsForDay, // Define o método para carregar eventos.
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedEvents,
                    builder: (BuildContext context, List<Event> events, _) {
                      return Container( // Cria um contêiner.
                        width: MediaQuery.of(context).size.width, // Define a largura como a largura da tela.
                        height: _calendarFormat == CalendarFormat.twoWeeks
                            ? MediaQuery.of(context).size.height / 1.5
                            : _calendarFormat == CalendarFormat.month
                                ? MediaQuery.of(context).size.height / 2.2
                                : _calendarFormat == CalendarFormat.week
                                    ? MediaQuery.of(context).size.height / 1.4
                                    : null, // Ajusta a altura com base no formato do calendário.
                        decoration: BoxDecoration( // Adiciona decoração ao contêiner.
                            color: c.cinza, // Define a cor de fundo.
                            border: Border(
                              top: BorderSide( color: c.preto, width: 1)
                            )
                            ),
                        child: events.length<=0
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Nenhuma atividade neste dia 😥'),
                          ],
                        )
                        :ListView.builder( // Cria uma lista de itens rolável.
                          itemCount: events.length, // Define o número de itens na lista.
                          itemBuilder: (context, index) => Padding( // Constrói cada item da lista.
                            padding: const EdgeInsets.all(8.0), // Define o preenchimento dos itens.
                            child: GestureDetector(
                              onTap: () => showModalBottomSheet(
                                backgroundColor: c.cinza,
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height/4,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Center(child: Text(snap[index]['nome_posto'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),)),
                                          Center(child: Text(snap[index]['nome_produto'], style: TextStyle(fontSize: 18),)),
                                          SizedBox(height: 20,),
                                          Text(snap[index]['data_criacao'], style: TextStyle(fontSize: 18),),
                                          const SizedBox(height: 10,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text("Cliente: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                                  Text(snap[index]['cliente'], style: TextStyle(fontSize: 18),),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text("Quantidade: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                                  Text(snap[index]['quantidade_comprada'], style: TextStyle(fontSize: 18),),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              child: Container( // Cria um contêiner para cada item.
                                padding: const EdgeInsets.all(10), // Define o preenchimento interno.
                                decoration: BoxDecoration( // Adiciona decoração ao contêiner.
                                    borderRadius: BorderRadius.circular(15), // Define os cantos arredondados.
                                    border: Border.all(width: 1)), // Adiciona uma borda ao contêiner.
                                child: Text(
                                  "${snap[index]['nome_posto']}", // Exibe o nome do produto ou um valor padrão.
                                  style: TextStyle(fontSize: 18), // Define o estilo do texto.
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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