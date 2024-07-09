import 'dart:convert'; // Importa la librería 'dart:convert' para la manipulación de datos JSON.

import 'package:PenaAventura/views/cores/cor.dart'; // Importa un archivo local con colores personalizados.
import 'package:PenaAventura/views/navbar/homepage.dart'; // Importa la página de inicio.
import 'package:flutter/material.dart'; // Importa el paquete Flutter para construir la interfaz de usuario.
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa el paquete para el manejo de preferencias compartidas.
import 'package:http/http.dart' as http; // Importa el paquete HTTP para realizar solicitudes a la web.

class Login extends StatefulWidget { // Define una clase de widget sin estado llamada 'Login'.
   Login({super.key}); 
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> { // Constructor de la clase 'Login' con una clave opcional.
  TextEditingController emailController = TextEditingController(); // Controlador para el campo de texto del email.
  TextEditingController passwordController = TextEditingController();  // Controlador para el campo de texto de la contraseña.
  String? email, palavra_passe;

  @override
  void initState() { //funcion que realizara cada vez que entre en la vista                                           
    super.initState();
    RememberMe();
  }

  RememberMe() async{ //funcion que realizara el loginm automatico en caso de que esten guardados dentro del celular el mail y la contrasenha
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    palavra_passe = prefs.getString('palavra-passe');
    if (email != null && palavra_passe != null) {
      setState(() {
        emailController.text = email!;
        passwordController.text = palavra_passe!;
      });
      loginFunction(context);
    }
    else{
      print("Sin mail ni passe");
    }
  }

  Future<void> loginFunction(BuildContext context) async { // Define una función asíncrona para manejar el inicio de sesión.
    if (emailController.text.isEmpty || passwordController.text.isEmpty) { // Verifica si los campos de texto están vacíos.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar( // Muestra un mensaje de error si los campos están vacíos.
        content: Center(
          child: Text('Datos insuficientes', style: TextStyle(
            color: c.branco, 
            fontWeight: FontWeight.bold
          ),),
        ),
        backgroundColor: Color.fromARGB(255, 216, 59, 48),
      ));
      return; // Sale de la función si hay datos insuficientes.
    }

    var url = Uri.parse('https://adminpena.oxb.pt/index.php/loginentrar'); // Define la URL de la solicitud de inicio de sesión.
    final response = await http.post( // Realiza una solicitud POST a la URL.
        url,
        body: {
          'email': emailController.text, // Pasa el email como parte del cuerpo de la solicitud.
          'password': passwordController.text, // Pasa la contraseña como parte del cuerpo de la solicitud.
        },
      );
    
    if (response.statusCode == 200) { // Verifica si la solicitud fue exitosa.
      var decodedData;
      try {
        decodedData = json.decode(response.body); // Intenta decodificar la respuesta JSON.
      } catch (e) {
        print('Error al decodificar la respuesta del servidor: $e'); // Imprime un mensaje de error si falla la decodificación.
      }

      if (decodedData != null && decodedData['status'] != null) { // Verifica si los datos decodificados y el estado no son nulos.
        if (decodedData['status']=='success' || decodedData['status'] == true) { // Verifica si el estado es 'success'.
          SharedPreferences prefs = await SharedPreferences.getInstance(); // Obtiene una instancia de preferencias compartidas.
          prefs.setInt('id', int.parse(decodedData['utilizador']['id'])); // Guarda el ID del usuario en las preferencias compartidas.
          prefs.setString('email', emailController.text); // Guarda el mail del usuario, esto para hacer el login automatico
          prefs.setString('palavra-passe', passwordController.text); // Guarda la contrasenha del usuario para el login automatico
          Navigator.push( // Navega a la página de inicio.
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar( // Muestra un mensaje de error si el inicio de sesión falla.
            content: Center(child: Text(decodedData['status_message'] ?? 'Error desconocido', style: TextStyle(color: c.branco, fontWeight: FontWeight.bold),)),
            backgroundColor: Color.fromARGB(255, 216, 59, 48),
          ));
        }
      } else {
        print("aqui rompe"); // Imprime un mensaje si los datos decodificados son nulos o no contienen un estado.
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar( // Muestra un mensaje de error si la solicitud no fue exitosa.
        content: Text('Error de conexión: ${response.statusCode} - ${response.reasonPhrase}', style: TextStyle(color: c.preto, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.amber[800],
      ));
      print('Error de conexión: ${response.statusCode} - ${response.reasonPhrase}'); // Imprime detalles del error de conexión.
    }
  }

  @override
  Widget build(BuildContext context) { // Define el método de construcción del widget.
    return Scaffold( // Retorna un widget Scaffold, que proporciona la estructura básica de la interfaz de usuario.
      body: Container( // Crea un contenedor para el cuerpo del Scaffold.
        color: c.azul_1, // Establece el color de fondo del contenedor con una opacidad del 60%.
        child:  Center( // Centra el contenido del contenedor.
          child: Container( // Crea un contenedor para el formulario de inicio de sesión.
            height: MediaQuery.of(context).size.height/1.5,
            width: MediaQuery.of(context).size.width/1.1, // Establece el ancho del contenedor.
            decoration: BoxDecoration( // Aplica decoraciones al contenedor.
           // Establece el color de fondo.
              borderRadius: BorderRadius.circular(10), // Redondea las esquinas.
            ),
            child: Column( // Crea una columna para organizar los elementos verticalmente.
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Centra los elementos verticalmente.
              crossAxisAlignment: CrossAxisAlignment.center, // Centra los elementos horizontalmente.
              children: [
                 Image.asset('assets/imagens/logo_branco.png'),
                //const SizedBox(height: 30,), // Añade un espacio vertical de 10 píxeles.
                Column( // Crea otra columna para los campos de texto.
                  children: [
                    Container( // Crea un contenedor para el campo de texto del email.
                      padding: const EdgeInsets.all(5), // Añade padding al contenedor.
                      decoration: BoxDecoration( // Aplica decoraciones al contenedor.
                        color: Colors.grey[200], // Establece el color de fondo.
                        borderRadius: BorderRadius.circular(50) // Redondea las esquinas.
                      ),
                      child: Theme( // Aplica un tema personalizado al campo de texto.
                        data: Theme.of(context).copyWith( // Copia el tema actual y aplica modificaciones.
                          primaryColor: c.azul_1, // Establece el color primario.
                          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith( // Copia el tema de decoración de entradas y aplica modificaciones.
                            iconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) { // Configura el color del ícono en función del estado.
                              if (states.contains(MaterialState.focused)) {
                                return c.azul_1; // Color cuando el campo está enfocado.
                              }
                              if (states.contains(MaterialState.error)) {
                                return c.azul_1; // Color cuando hay un error.
                              }
                              return Colors.grey; // Color por defecto.
                            }),
                          ),
                        ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField( // Crea un campo de texto.
                          controller: emailController, // Asigna el controlador del email.
                          cursorColor: c.preto, // Establece el color del cursor.
                          obscureText: false, // El texto no es oculto.
                          decoration:  InputDecoration( // Aplica decoraciones al campo de texto.
                            labelStyle: TextStyle(color: c.preto), // Establece el estilo del texto de la etiqueta.
                            icon: Icon(Icons.person), // Añade un ícono al campo de texto.
                            label: Text("Correo eletrónico"), // Añade una etiqueta al campo de texto.
                            border: InputBorder.none, // Sin borde.
                            filled: false, // El campo no está lleno.
                          ),
                          
                        ),
                      ),
                      ),
                    ),
                    const SizedBox(height: 10,), // Añade un espacio vertical de 10 píxeles.
                    Container( // Crea un contenedor para el campo de texto de la contraseña.
                      padding: const EdgeInsets.all(5), // Añade padding al contenedor.
                      decoration: BoxDecoration( // Aplica decoraciones al contenedor.
                        color: c.cinza, // Establece el color de fondo.
                        borderRadius: BorderRadius.circular(50) // Redondea las esquinas.
                      ),
                      child: Theme( // Aplica un tema personalizado al campo de texto.
                        data: Theme.of(context).copyWith( // Copia el tema actual y aplica modificaciones.
                          primaryColor: c.azul_1, // Establece el color primario.
                          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith( // Copia el tema de decoración de entradas y aplica modificaciones.
                            iconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) { // Configura el color del ícono en función del estado.
                              if (states.contains(MaterialState.focused)) {
                                return c.azul_1; // Color cuando el campo está enfocado.
                              }
                              if (states.contains(MaterialState.error)) {
                                return c.azul_1; // Color cuando hay un error.
                              }
                              return Colors.grey; // Color por defecto.
                            }),
                          ),
                        ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField( // Crea un campo de texto.
                          controller: passwordController, // Asigna el controlador de la contraseña.
                          cursorColor: c.preto, // Establece el color del cursor.
                          obscureText: true, // El texto es oculto.
                          decoration: const InputDecoration( // Aplica decoraciones al campo de texto.
                            labelStyle: TextStyle(color: c.preto), // Establece el estilo del texto de la etiqueta.
                            icon: Icon(Icons.lock), // Añade un ícono al campo de texto.
                            label: Text("Palavra-passe"), // Añade una etiqueta al campo de texto.
                            border: InputBorder.none, // Sin borde.
                            filled: false, // El campo no está lleno.
                          ),
                        ),
                      ),
                      ),
                    ),
                const SizedBox(height: 10,), // Añade un espacio vertical de 10 píxeles.
                GestureDetector( // Crea un detector de gestos.
                  onTap: ()=>loginFunction(context), // Llama a la función de inicio de sesión cuando se toca.
                  child: Container( // Crea un contenedor para el botón de inicio de sesión.
                    width: MediaQuery.of(context).size.width, // Establece el ancho del contenedor.
                    padding: const EdgeInsets.all(10), // Añade padding al contenedor.
                    decoration: BoxDecoration( // Aplica decoraciones al contenedor.
                      color: c.verde_1, // Establece el color de fondo.
                      borderRadius: BorderRadius.circular(50) // Redondea las esquinas.
                    ),
                    child: const Center( // Centra el contenido del contenedor.
                      child: Text("Iniciar sessão", style: TextStyle( // Añade un texto al botón de inicio de sesión.
                        color: c.branco, // Establece el color del texto.
                        fontSize: 21) // Establece el tamaño del texto.
                        )
                      ),
                    )
                ),
                  ],
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

}
