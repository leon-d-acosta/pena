import 'package:PenaAventura/cor.dart';
import 'package:PenaAventura/views/perfil.dart';
import 'package:PenaAventura/views/postos.dart';
import 'package:PenaAventura/views/qr_scanner.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final views = [
      const Postos(),
      const Qr_Scanner(),
      const Perfil(),
    ];

    return Scaffold(
      body: views[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        buttonBackgroundColor: Cor.azul_1,
        backgroundColor: Cor.cinza!,
        color: Cor.azul_1,
        animationDuration: const Duration(milliseconds: 300),
        height: 60,
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          Icon(Icons.list, color: Cor.branco, size: 30,),
          Icon(Icons.qr_code_scanner, color: Cor.branco, size: 30,),
          Icon(Icons.account_circle, color: Cor.branco, size: 30,),
        ],
      ),
    );
  }
}