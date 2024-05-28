import 'package:flutter/material.dart';
import 'package:PenaAventura/views/cores/cor.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  ValueNotifier<List<bool>> _formatChanger = ValueNotifier<List<bool>>([]); // Lista para controlar a expansão dos painéis


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.branco,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TableCalendar(
                locale: 'pt_PT',
                firstDay: DateTime.utc(2022, 1, 1),
                lastDay: DateTime.utc(2030, 1, 1),
                focusedDay: DateTime.now(),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: _calendarFormat == CalendarFormat.twoWeeks
                                              ? MediaQuery.of(context).size.height/1.75
                                              : _calendarFormat == CalendarFormat.month
                                              ? MediaQuery.of(context).size.height/2.75
                                              : _calendarFormat == CalendarFormat.week
                                              ? MediaQuery.of(context).size.height/1.5
                                              :null,
                  decoration: BoxDecoration(
                    color: c.azul_2.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30)
                  ),
                ),
              ),
            ],
          ),
        ),
      ), 
    );
  }
}