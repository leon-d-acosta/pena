import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:PenaAventura/views/postos/qr_tarefa/search_tarefa/search_tarefa.dart';
import 'package:PenaAventura/views/cores/cor.dart';

final TextEditingController idController = TextEditingController();

class Qr_Scanner extends StatefulWidget {
  final String id_posto;
  const Qr_Scanner({Key? key, required this.id_posto}) : super(key: key);

  @override
  State<Qr_Scanner> createState() => _Qr_ScannerState();
}

class _Qr_ScannerState extends State<Qr_Scanner> {
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: MediaQuery.of(context).size.height / 5,
                    width: constraints.maxWidth,
                    color: c.cinza,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("QRCODE", style: TextStyle(color: c.verde_2, fontSize: 30, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: TextField(
                            controller: idController,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            if(idController.text.isNotEmpty) {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context)=>SearchTarefa(id_posto: widget.id_posto, qr: idController.text)
                              )
                            ).then((_) => idController.clear());
                            }
                          },
                          child: Container(
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: c.verde_2,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const Center(child: Text("Pesquisar", style: TextStyle(color: c.branco, fontSize: 15, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey, // Cambia al color deseado
                      child: MobileScanner(
                        controller: MobileScannerController(detectionSpeed: DetectionSpeed.normal),
                        onDetect: (capture) {
                          if (!_redirecting) {
                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              print("Barcode: ${barcode.rawValue}");
                            }
                            if (barcodes.isNotEmpty) {
                              setState(() {
                                _redirecting = true;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchTarefa(id_posto: widget.id_posto, qr: barcodes[0].rawValue.toString()),
                                ),
                              ).then((value) {
                                setState(() {
                                  _redirecting = false; // Re-enable scanning when returning from SearchTarefa
                                });
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          foregroundColor: c.branco,
          backgroundColor: c.azul_1,
          elevation: 10,
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
