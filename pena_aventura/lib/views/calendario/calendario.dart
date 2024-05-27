import 'package:flutter/material.dart';
import 'package:PenaAventura/views/cores/cor.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.branco,
    );
  }
}