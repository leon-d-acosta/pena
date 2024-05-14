import 'dart:convert';
import 'package:PenaAventura/views/cores/cor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeNomeAlert extends StatefulWidget {
  final String nome;
  const ChangeNomeAlert({Key? key, required this.nome}) : super(key: key);

  @override
  State<ChangeNomeAlert> createState() => _ChangeNomeAlertState();
}

class _ChangeNomeAlertState extends State<ChangeNomeAlert> {

  final nomeController = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<int?> getid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }


  Future<void> _authenticateWithBiometrics() async {
    try {
      bool isBiometricSupported = await _localAuthentication.isDeviceSupported();
      if (isBiometricSupported) {
        bool isBiometricAvailable = await _localAuthentication.authenticate(
          localizedReason: 'Por favor, autentica para cambiar el nombre',
        );
        if (isBiometricAvailable) {
          // Autenticación biométrica exitosa, cambia los datos
          changeData();
        }
      } else {
        // Dispositivo no compatible con la autenticación biométrica
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El dispositivo no soporta autenticación biométrica'),
          ),
        );
      }
    } catch (e) {
      print('Error en la autenticación biométrica: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en la autenticación biométrica: $e'),
        ),
      );
    }
  }

  void openBottomSheetSuccess(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 8,
                child: Lottie.network("https://lottie.host/853a2a85-7c9a-4278-ae33-5b7a7a65b873/gpwzArdGJN.json", fit: BoxFit.cover),
              ),
              const Text("Inforamação trocada com sucesso", style: TextStyle(color: c.verde_1, fontSize: 20)),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 2100), () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
  }

  Future<void> changeData() async {
    if (nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Datos insuficientes'),
      ));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt('id') ?? 0;

    var url = Uri.parse('https://lavandaria.oxb.pt/index.php/editar_perfil_app');
    //var url = Uri.parse('http://10.0.0.53/xampp/project_oxb/project1/lib/pages/db/perfil_db/updatesPerfil/updateNome.php');
    var response  = await http.post(url, body: {
      'id_utilizador': id.toString(),
      'nome': nomeController.text,
    });

    if (response.statusCode == 200) {
      var decodedData;
      try {
        decodedData = json.decode(response.body);
      } catch (e) {
        print('Error al decodificar la respuesta del servidor: $e');
      }
      if (decodedData != null && decodedData['status'] != null) {
        if (decodedData['status'] == 'success') {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(decodedData['status_message'] ?? 'Error desconocido'),
          ));
        }
      } else {
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error de conexión: ${response.statusCode} - ${response.reasonPhrase}'),
      ));
      print('Error de conexión: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trocar meu nome", style: TextStyle(color: c.branco)),
        foregroundColor: c.branco,
        backgroundColor: c.azul_1.withAlpha(255),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: c.cinza,
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: MediaQuery.of(context).orientation == Orientation.portrait
                                                            ?MediaQuery.of(context).size.height / 5
                                                            :MediaQuery.of(context).size.height / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Meu nome atual:", style: TextStyle(color: c.preto, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(widget.nome, style: const TextStyle(color: c.azul_1, fontSize: 30, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  TextField(
                    controller: nomeController,
                    obscureText: false,
                    decoration:   InputDecoration(
                        labelText: "Novo nome",
                        labelStyle: const TextStyle(
                          color: c.preto,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(),
                        filled: false,
                        hintText: "Nome do utilizador",
                        hintStyle: TextStyle(
                          color: c.preto.withOpacity(0.3),
                        )),
                  ),
                ],
              ),
            ),
              Lottie.network("https://lottie.host/8d7c8501-f8c9-4f93-8d1e-e0673d5476b6/H2VncRqa1x.json", 
                height: MediaQuery.of(context).orientation == Orientation.portrait?null:0,
                width: MediaQuery.of(context).orientation == Orientation.portrait?null:0
              ),            GestureDetector(
              onTap: _authenticateWithBiometrics,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: c.verde_1,
                ),
                child: const Center(
                  child: Text('Salvar alteração', style: TextStyle(color: c.branco, fontSize: 18)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
