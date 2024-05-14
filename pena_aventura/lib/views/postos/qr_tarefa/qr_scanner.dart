import 'package:PenaAventura/views/cores/cor.dart';
import 'package:PenaAventura/views/perfil/perfil.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Qr_Scanner extends StatefulWidget {
  const Qr_Scanner({super.key});

  @override
  State<Qr_Scanner> createState() => _Qr_ScannerState();
}

class _Qr_ScannerState extends State<Qr_Scanner> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height/4,
              width: MediaQuery.of(context).size.width,
              color: Cor.cinza,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pesquisar por", style: TextStyle(color: Colors.black, fontSize: 20),),
                  const Text("ID", style: TextStyle(color: Cor.verde_1, fontSize: 30, fontWeight: FontWeight.bold),),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: const TextField(),
                  ),
                  const SizedBox(height: 10,),
                  GestureDetector(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Cor.verde_1,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Center(child: Text("Pesquisar", style: TextStyle(color: Cor.branco, fontSize: 15, fontWeight: FontWeight.bold),)),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height/1.55,
              color: Cor.cinza,
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
    );
  }
}