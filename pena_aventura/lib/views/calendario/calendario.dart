import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:PenaAventura/views/cores/cor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class Calendario extends StatefulWidget {
  const Calendario({Key? key}) : super(key: key);

  @override
  State<Calendario> createState() => _CalendarioState();
}

class Event {
  final String title;
  final String nome_posto;
  final String nome_produto;
  final String data_criacao;
  final String cliente;
  final String quantidade_comprada;

  Event({
    required this.title,
    required this.nome_posto,
    required this.nome_produto,
    required this.data_criacao,
    required this.cliente,
    required this.quantidade_comprada,
  });

  @override
  String toString() => title;
}

class _CalendarioState extends State<Calendario> {
  late Future<void> _futureData;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  late final ValueNotifier<List<Event>> _selectedEvents;
  late final ValueNotifier<Map<DateTime, List<Event>>> _filteredEventsNotifier;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _filteredEventsNotifier = ValueNotifier({});
    _futureData = _refreshView(); // Inicializa _futureData correctamente
  }

  Future<void> _refreshView() async {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    await _getFilteredData(firstDayOfMonth, lastDayOfMonth);
  }

  Future<int?> _getid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<void> _getFilteredData(DateTime startDate, DateTime endDate) async {
    int id = (await _getid()) ?? 0;
    var url = Uri.parse('https://adminpena.oxb.pt/index.php/execucaoatividadesapp');
    var response = await http.post(url, body: {
      'id_utilizador': id.toString(),
      'data_inicio': startDate.toIso8601String(),
      'data_fim': endDate.toIso8601String()
    });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['registos'];
      Map<DateTime, List<Event>> newEvents = {};
      for (var item in data) {
        DateTime eventDate = DateTime.parse(item['data_criacao']);
        eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (newEvents[eventDate] == null) {
          newEvents[eventDate] = [];
        }
        newEvents[eventDate]!.add(
          Event(
            title: item['nome_produto'] ?? '',
            nome_posto: item['nome_posto'] ?? '',
            nome_produto: item['nome_produto'] ?? '',
            data_criacao: item['data_criacao'] ?? '',
            cliente: item['cliente'] ?? '',
            quantidade_comprada: item['quantidade_comprada'] ?? '',
          ),
        );
      }
      setState(() {
        _events = newEvents;
        _filteredEventsNotifier.value = newEvents;
      });
    } else {
      throw Exception('Erro ao obter os dados');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  void _onMonthChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _refreshView();
    });
  }

  List<Event> _getEventsForDay(DateTime dataselecionada) {
    List<Event> eventsForSelectedDay = [];
    _events.forEach((key, value) {
      if (key.year == dataselecionada.year && key.month == dataselecionada.month && key.day == dataselecionada.day) {
        eventsForSelectedDay.addAll(value);
      }
    });
    return eventsForSelectedDay;
  }

  void _loadMoreEvents(DateTime selectedDay) {
    setState(() {
      _selectedEvents.value = _getEventsForDay(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.cinza,
      body: SafeArea(
        child: FutureBuilder(
          future: _futureData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error ${snapshot.error}"));
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  TableCalendar(
                    locale: 'pt_PT',
                    firstDay: DateTime.utc(2022, 1, 1),
                    lastDay: DateTime.utc(2030, 1, 1),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: _onDaySelected,
                    onPageChanged: _onMonthChanged,
                    calendarFormat: _calendarFormat,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mensal',
                      CalendarFormat.twoWeeks: '2 semanas',
                      CalendarFormat.week: 'Semanal',
                    },
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: c.azul_1),
                      weekendStyle: TextStyle(color: Colors.red),
                    ),
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    calendarStyle: const CalendarStyle(markersAlignment: Alignment.bottomRight),
                    eventLoader: _getEventsForDay,
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) => events.isNotEmpty
                          ? Container(
                              width: 15,
                              height: 15,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.lightBlue,
                              ),
                              child: Text(
                                '${events.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            )
                          : null,
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedEvents,
                    builder: (BuildContext context, List<Event> events, _) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: _calendarFormat == CalendarFormat.twoWeeks
                            ? MediaQuery.of(context).size.height / 1.5
                            : _calendarFormat == CalendarFormat.month
                                ? MediaQuery.of(context).size.height / 2.2
                                : _calendarFormat == CalendarFormat.week
                                    ? MediaQuery.of(context).size.height / 1.4
                                    : null,
                        decoration: BoxDecoration(
                          color: c.cinza,
                          border: Border(top: BorderSide(color: c.preto, width: 1)),
                        ),
                        child: events.length <= 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Nenhuma atividade neste dia'),
                                ],
                              )
                            : ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () => showModalBottomSheet(
                                      backgroundColor: c.cinza,
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Container(
                                            height: MediaQuery.of(context).size.height / 4,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Text(
                                                    events[index].nome_posto,
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    events[index].nome_produto,
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Text(
                                                  events[index].data_criacao,
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Cliente: ",
                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                        ),
                                                        Text(
                                                          events[index].cliente,
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Quantidade: ",
                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                        ),
                                                        Text(
                                                          events[index].quantidade_comprada,
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(width: 0.5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  events[index].title,
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: false,
                                                  maxLines: 2,
                                                  textScaler: TextScaler.linear(0.8),
                                                ),
                                              ),
                                              Text(
                                                "${events[index].quantidade_comprada} Qtd",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              )
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(events[index].nome_posto),
                                              Text(
                                                "${events[index].data_criacao}",
                                                style: TextStyle(color: c.azul_1),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                  if (_selectedEvents.value.length > 5)
                    TextButton(
                      onPressed: () => _loadMoreEvents(_selectedDay!),
                      child: Text('Carregar mais eventos'),
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
