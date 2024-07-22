import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:PenaAventura/views/cores/cor.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? email, palavra_passe;
  bool _showPopup = false; // Bandera para controlar la visualización del popup

  @override
  void initState() {
    super.initState();
    minha_versao(); //O PRIMEIRO QUE FAZ AO ENTRAR À VISTA DO LOGIN É PEDIR A VERSAO DA APP
    _showPopup = false; // Inicialmente el popup no se muestra
    RememberMe(); // Verifica el inicio de sesión automático si hay credenciales guardadas
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mostrar el popup solo una vez después de que initState ha completado
    if (!_showPopup) {
      _showPopup = true;
      showPopup(); // Llama al método para mostrar el popup
    }
  }

  Future<String> minha_versao() async { // ESTA FUNÇÃO É UM GETTER DA VERSÃO ATUAL DA APP
    PackageInfo pInfo = await PackageInfo.fromPlatform();
    String versao = pInfo.version;
    print("minha versao: $versao");
    return versao;
  }

  verificacao_versao(String minha_versao) async {
    /*
    AQUI HÁ QUE IMPLEMENTAR A VERIFICAÇÃO DA VERSÃO QUE TEM O USUARIO E A VERSÃO DO JSON NA BASE DE DADOS
    NO CASO DE "MINHA_VERSAO" SER DIFERENTE À DO JSON, TEM QUE SALTAR LA FUNÇÃO SHOWPOPUP(), SE SÃO IGUAIS, NAO FAZ NADA
     */
  }

  void showPopup() async { // FUNÇÃO ENCARREGADA DE MOSTRAR O POPUP
    await Future.delayed(Duration(milliseconds: 50)); // ESPERA 50 MILISEGUNDOS PARA MOSTRAR O POPUP
    showDialog( 
      context: context,
      builder: (BuildContext context) {
        return AlertDialog( //O POPUP
          title: Text("Há uma atualização disponivel"), //TITULO DO POPUP
          content: Text("Descarregue há última versão da aplicação."), // O TEXTO DO CONTENIDO DO POPUP
          actions: <Widget>[
            TextButton( //BOTÃO DE DESCARREGAR A APK
              child: Text("Descarregar"),
              onPressed: () { //O QUE VAI FAZER QUANDO PIQUEMOS NO BOTÃO
                const String fileUrl = "https://adminpena.oxb.pt/assets/mobile/penaaventura.apk"; //VARIAVEL COM O LINK ONDE ESTA A APK
                FileDownloader.downloadFile( //WIDGET PARA DESCARREGAR FICHEIROS
                  url: fileUrl, //URL DO APK, PREVIAMENTE ALMACENADO NUMA VARIAVEL
                  name: 'penaaventura.apk', //NOME QUE VAI TER O FICHEIRO DESCARREGADO
                  onProgress: (fileName, progress) => print('File $fileName has progress $progress'),
                  onDownloadCompleted: (path) {//NO CASO DE COMPLETAR COM SUCCESSO A DESCARGA DA APK, MOSTRA UM SNACKAR VERDE
                    print('Downloaded: $path');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Descarga completada: $path'),
                      backgroundColor: Colors.green,
                    ));
                  },
                  onDownloadError: (errorMessage) { // NO CASO DE NAO CENSEGUER DESCARREGAR A APK, MOSRA UN SNACKBAR VERMELHO
                    print('downloadError: $errorMessage');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error de descarga: $errorMessage'),
                      backgroundColor: Colors.red,
                    ));
                  },
                  notificationType: NotificationType.all //MOSTRA COMO NOTIFICAÇÃO A DESCARGA E O ESTADO DA MESMA
                );
              },
            ),
          ],
        );
      },
    );
  }

  RememberMe() async {//FUNÇÃO PARA VER NA MEMORIA SE JA TEMOS FEITO ALGUM LOGIN, NO CASO DE TER FEITO, VAI USAR O EMAIL E A SENHA USADAS POR ULTIMA VEZ
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    palavra_passe = prefs.getString('palavra-passe');
    if (email != null && palavra_passe != null) {
      setState(() {
        emailController.text = email!;
        passwordController.text = palavra_passe!;
      });
    } else {
      print("Sin mail ni passe");
    }
  }

  Future<void> loginFunction(BuildContext context) async { // FUNÇÃO PARA REALIZAR O LOGIN
    if (emailController.text.isEmpty || passwordController.text.isEmpty) { //IF PARA VERIFICAR QUE LOS TEXTFIELD NO ESTAN VACIOS CUANDO PIQUEMOS NO BOTÃO "INICIAR SESSAO"
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(
          child: Text(
            'Datos insuficientes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }

    var url = Uri.parse('https://adminpena.oxb.pt/index.php/loginentrar');
    final response = await http.post(
      url,
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      var decodedData;
      try {
        decodedData = json.decode(response.body);
      } catch (e) {
        print('Error al decodificar la respuesta del servidor: $e');
      }

      if (decodedData != null && decodedData['status'] != null) {
        if (decodedData['status'] == 'success' || decodedData['status'] == true) { //NO CASO DE TER TIDO SUCESSO NO LLGIN, VAI GUARDAR NA MEMORIA O EMAIL, A SENHA E O ID DO USUARIO LOGADO
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('id', int.parse(decodedData['utilizador']['id']));
          prefs.setString('email', emailController.text);
          prefs.setString('palavra-passe', passwordController.text);
          Navigator.pushReplacementNamed(context, '/homepage'); // Navega a la página de inicio y reemplaza la pila de navegación
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Center(
              child: Text(
                decodedData['status_message'] ?? 'Error desconocido',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        print("aqui rompe");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Error de conexión: ${response.statusCode} - ${response.reasonPhrase}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
      ));
      print('Error de conexión: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

@override
  Widget build(BuildContext context) {
    // Retorna o widget Scaffold, que é uma estrutura básica para material design.
    return Scaffold(
      // Corpo do Scaffold.
      body: Container(
        // Cor de fundo do container principal.
        color: Colors.blue,
        child: Center(
          // Alinha o widget filho no centro da tela.
          child: Container(
            // Define a altura e largura do container com base no tamanho da tela.
            height: MediaQuery.of(context).size.height / 1.5,
            width: MediaQuery.of(context).size.width / 1.1,
            // Define a decoração do container.
            decoration: BoxDecoration(
              // Bordas arredondadas para o container.
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              // Alinha os widgets filhos verticalmente com espaço ao redor.
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // Alinha os widgets filhos horizontalmente no centro.
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagem do logotipo.
                Image.asset('assets/imagens/logo_branco.png'),
                Column(
                  children: [
                    // Primeiro campo de entrada (email).
                    Container(
                      padding: const EdgeInsets.all(5),
                      // Decoração do container com fundo cinza claro e bordas arredondadas.
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Theme(
                        // Tema aplicado ao campo de texto.
                        data: Theme.of(context).copyWith(
                          primaryColor: c.azul_1,
                          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                            // Define a cor do ícone baseado no estado do campo.
                            iconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                              if (states.contains(MaterialState.focused)) {
                                return c.azul_1;
                              }
                              if (states.contains(MaterialState.error)) {
                                return c.azul_1;
                              }
                              return Colors.grey;
                            }),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: TextField(
                            // Controlador para o campo de email.
                            controller: emailController,
                            cursorColor: c.preto,
                            obscureText: false,
                            // Decoração do campo de texto.
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: c.preto),
                              icon: Icon(Icons.person),
                              label: Text("Correo eletrónico"),
                              border: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Espaçamento entre os campos de entrada.
                    const SizedBox(height: 10),
                    // Segundo campo de entrada (senha).
                    Container(
                      padding: const EdgeInsets.all(5),
                      // Decoração do container com fundo cinza e bordas arredondadas.
                      decoration: BoxDecoration(
                        color: c.cinza,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Theme(
                        // Tema aplicado ao campo de texto.
                        data: Theme.of(context).copyWith(
                          primaryColor: c.azul_1,
                          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                            // Define a cor do ícone baseado no estado do campo.
                            iconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                              if (states.contains(MaterialState.focused)) {
                                return c.azul_1;
                              }
                              if (states.contains(MaterialState.error)) {
                                return c.azul_1;
                              }
                              return Colors.grey;
                            }),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: TextField(
                            // Controlador para o campo de senha.
                            controller: passwordController,
                            cursorColor: c.preto,
                            obscureText: true,
                            // Decoração do campo de texto.
                            decoration: const InputDecoration(
                              labelStyle: TextStyle(color: c.preto),
                              icon: Icon(Icons.lock),
                              label: Text("Palavra-passe"),
                              border: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Espaçamento entre os campos de entrada e o botão.
                    const SizedBox(height: 10),
                    // Botão para iniciar sessão.
                    GestureDetector(
                      onTap: () => loginFunction(context),
                      child: Container(
                        // Largura do botão igual à largura da tela.
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(10),
                        // Decoração do botão com fundo verde e bordas arredondadas.
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          // Texto centralizado no botão.
                          child: Text(
                            "Iniciar sessão",
                            style: TextStyle(color: Colors.white, fontSize: 21),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

