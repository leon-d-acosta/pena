import 'package:PenaAventura/views/calendario/calendario.dart';
import 'package:PenaAventura/views/cores/cor.dart';
import 'package:PenaAventura/views/info_picagem/info_picagem.dart';
import 'package:PenaAventura/views/perfil/perfil.dart';
import 'package:PenaAventura/views/postos/postos.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final views = [
      const Postos(),
      const InfoPicagem(),
      Calendario(),
      const Perfil(),
    ];

    return Scaffold(
      body: views[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        buttonBackgroundColor:c.verde_2,
        backgroundColor: c.cinza,
        color: c.azul_1,
        animationDuration: const Duration(milliseconds: 300),
        height: 60,
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          Icon(
            Icons.qr_code, 
            color: c.branco, 
            size: 30,
            ),
          Icon(
            Icons.list_alt,
            color: c.branco,
            size: 30,
          ),
          Icon(
            Icons.calendar_month_rounded,
            color: c.branco,
            size: 30,
          ),
          Icon(
            Icons.account_circle, 
            color: c.branco, 
            size: 30,
            ),
        ],
      ),
    );
  }
}