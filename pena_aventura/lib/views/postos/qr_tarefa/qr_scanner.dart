import 'package:flutter/material.dart'; // Importa o pacote Flutter Material Design
import 'package:flutter/services.dart'; // Importa o pacote de serviços do Flutter
import 'package:mobile_scanner/mobile_scanner.dart'; // Importa o pacote de scanner móvel
import 'package:PenaAventura/views/postos/qr_tarefa/search_tarefa/search_tarefa.dart'; // Importa a tela de pesquisa de tarefas
import 'package:PenaAventura/views/cores/cor.dart'; // Importa as cores do aplicativo

final TextEditingController idController = TextEditingController(); // Controlador para o campo de texto do ID

class Qr_Scanner extends StatefulWidget { // Classe para a tela de scanner QR
  final String id_posto; // ID do posto
  const Qr_Scanner({Key? key, required this.id_posto}) : super(key: key); // Construtor da classe

  @override
  State<Qr_Scanner> createState() => _Qr_ScannerState(); // Cria um estado para a tela de scanner QR
}

class _Qr_ScannerState extends State<Qr_Scanner> { // Estado da tela de scanner QR
  bool _redirecting = false; // Variável para controlar o redirecionamento

  @override
  void initState() { // Método chamado ao inicializar o estado
    super.initState(); // Chama o método initState da classe pai
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Define a orientação do dispositivo para retrato
  }

  @override
  void dispose() { // Método chamado ao descartar o estado
    SystemChrome.setPreferredOrientations([ // Define as orientações preferidas do dispositivo
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.dispose(); // Chama o método dispose da classe pai
  }

  @override
  Widget build(BuildContext context) { // Método para construir a interface do usuário
    return SafeArea( // Retorna um widget de área segura
      child: Scaffold( // Retorna um widget de Scaffold
        body: LayoutBuilder( // Constrói um widget com base nas restrições de layout
          builder: (context, constraints) { // Construtor do widget com base no contexto e nas restrições
            return SizedBox( // Retorna um widget de tamanho fixo
              height: constraints.maxHeight, // Define a altura máxima do widget
              width: constraints.maxWidth, // Define a largura máxima do widget
              child: Column( // Coluna de widgets
                children: [
                  Container( // Contêiner para o cabeçalho
                    padding: const EdgeInsets.all(10), // Preenchimento do contêiner
                    height: MediaQuery.of(context).size.height / 5, // Altura do contêiner
                    width: constraints.maxWidth, // Largura do contêiner
                    color: c.branco, // Cor de fundo do contêiner
                    child: Column( // Coluna de widgets
                      crossAxisAlignment: CrossAxisAlignment.start, // Alinhamento cruzado dos widgets
                      children: [
                        const Text("QRCODE", style: TextStyle(color: c.verde_2, fontSize: 30, fontWeight: FontWeight.bold)), // Título
                        Container( // Contêiner para o campo de texto do ID
                          padding: const EdgeInsets.only(left: 10), // Preenchimento do contêiner
                          child: TextField( // Campo de texto
                            controller: idController, // Controlador do campo de texto
                          ),
                        ),
                        const SizedBox(height: 10), // Espaçamento vertical
                        GestureDetector( // Widget GestureDetector para lidar com toques
                          onTap: () { // Função chamada ao tocar no GestureDetector
                            if(idController.text.isNotEmpty) { // Verifica se o campo de texto não está vazio
                            Navigator.push( // Navega para a tela de pesquisa de tarefas
                              context, 
                              MaterialPageRoute(
                                builder: (context)=>SearchTarefa(id_posto: widget.id_posto, qr: idController.text)
                              )
                            ).then((_) => idController.clear()); // Limpa o campo de texto após a navegação
                            }
                          },
                          child: Container( // Contêiner para o botão de pesquisa
                            width: constraints.maxWidth, // Largura do contêiner
                            decoration: BoxDecoration( // Decoração do contêiner
                              color: c.verde_2, // Cor de fundo
                              borderRadius: BorderRadius.circular(5), // Borda arredondada
                            ),
                            padding: const EdgeInsets.all(10), // Preenchimento do contêiner
                            child: const Center(child: Text("Pesquisar", style: TextStyle(color: c.branco, fontSize: 15, fontWeight: FontWeight.bold))), // Texto do botão
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded( // Widget expandido
                    child: Container( // Contêiner para o scanner móvel
                      color: Colors.grey, // Cor de fundo do contêiner (pode ser alterada para a cor desejada)
                      child: MobileScanner( // Widget de scanner móvel
                        controller: MobileScannerController(detectionSpeed: DetectionSpeed.normal), // Controlador do scanner móvel com velocidade de detecção normal
                        onDetect: (capture) { // Função chamada ao detectar um código QR
                          if (!_redirecting) { // Verifica se não está redirecionando
                            final List<Barcode> barcodes = capture.barcodes; // Obtém os códigos de barras detectados
                            for (final barcode in barcodes) { // Loop através dos códigos de barras
                              print("Barcode: ${barcode.rawValue}"); // Exibe o valor do código de barras no console
                            }
                            if (barcodes.isNotEmpty) { // Verifica se há códigos de barras detectados
                              setState(() { // Atualiza o estado do widget
                                _redirecting = true; // Define _redirecting como verdadeiro para evitar redirecionamentos múltiplos
                              });
                              Navigator.push( // Navega para a tela de pesquisa de tarefas
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchTarefa(id_posto: widget.id_posto, qr: barcodes[0].rawValue.toString()),
                                ),
                              ).then((value) { // Após retornar da tela de pesquisa de tarefas
                                setState(() { // Atualiza o estado do widget
                                  _redirecting = false; // Define _redirecting como falso para permitir a digitalização novamente
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
        floatingActionButton: FloatingActionButton( // Botão de ação flutuante
          onPressed: () => Navigator.pop(context), // Função chamada ao pressionar o botão (navega de volta)
          foregroundColor: c.branco, // Cor do ícone do botão
          backgroundColor: c.azul_1, // Cor de fundo do botão
          elevation: 10, // Elevação do botão
          child: const Icon(Icons.arrow_back), // Ícone do botão
        ),
      ),
    );
  }
}

