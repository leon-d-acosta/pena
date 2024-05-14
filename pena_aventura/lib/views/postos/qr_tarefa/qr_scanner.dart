import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:PenaAventura/views/cores/cor.dart';
import 'package:PenaAventura/views/perfil/perfil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

final TextEditingController idController = TextEditingController();

class Qr_Scanner extends StatefulWidget {
  final String nome_atividade;
  const Qr_Scanner({super.key, required this.nome_atividade});

  @override
  State<Qr_Scanner> createState() => _Qr_ScannerState();
}

class _Qr_ScannerState extends State<Qr_Scanner> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              height: MediaQuery.of(context).size.height/3.5,
              width: MediaQuery.of(context).size.width,
              color: c.cinza,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pesquisar por", style: TextStyle(color: c.preto, fontSize: 20),),
                  const Text("ID", style: TextStyle(color: c.verde_1, fontSize: 30, fontWeight: FontWeight.bold),),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: idController,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  GestureDetector(
                    onTap: () => print(idController.text),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: c.verde_1,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Center(child: Text("Pesquisar", style: TextStyle(color: c.branco, fontSize: 15, fontWeight: FontWeight.bold),)),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height/1.3,
              color: c.cinza,
              child: MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.noDuplicates,
                ),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    print("Barcode: ${barcode.rawValue}");
                  }
                  if (barcodes.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Perfil(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>Navigator.pop(context),
        foregroundColor: c.branco,
        backgroundColor: c.azul_1,
        elevation: 10,
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}