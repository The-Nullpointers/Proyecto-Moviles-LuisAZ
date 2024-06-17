import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  // Controladores para los campos de texto
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _cedulaController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Inicialización de los controladores de texto
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _cedulaController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {

    // Proveedor de autenticación
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 80,),
              
              // Icono y título de la aplicación
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 10, color: Colors.black)
                ),
                child: const Icon(
                  Icons.sports_gymnastics_rounded,
                  size: 150,
                ),
              ),
              
              Text(
                "*Null's Gym",
                style: TextStyles.titles(),
              ),
              
              // Subtítulo "Registrarse"
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  "Registrarse",
                  style: TextStyles.subtitles(fontSize: 25),
                ),
              ),

              // Campo de texto para la cédula
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 20,
                  right: 20,
                ),
                child: TextField(
                  controller: _cedulaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLength: 12,
                  decoration: InputDecoration(
                    labelText: 'Identificación',
                    counterText: "",
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),

              // Mensaje de error para la cédula
              if(authProvider.errorCedula)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    "(!) La identificación debe ser Nacional o DIMEX",
                    style: TextStyles.errorMessages(),
                  ),
                ),

              // Campo de texto para el nombre completo
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 20,
                  right: 20,
                ),
                child: TextField(
                  controller: _nameController,
                  maxLength: 50,
                  decoration: InputDecoration(
                    counterText: "",
                    labelText: 'Nombre Completo',
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              
              // Campo de texto para el correo electrónico
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 20,
                  right: 20,
                ),
                child: TextField(
                  controller: _emailController,
                  maxLength: 50,
                  decoration: InputDecoration(
                    counterText: "",
                    labelText: 'Correo Electrónico',
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              
              // Mensaje de error para el correo
              if(authProvider.errorEmail)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    "(!) El correo no es válido",
                    style: TextStyles.errorMessages(),
                  ),
                ),
              
              // Campo de texto para la contraseña
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  right: 20,
                  left: 20,
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  maxLength: 30,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    counterText: "Min: 8 caracteres",
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),

              // Mensaje de error para la contraseña no segura
              if(authProvider.errorPasswordNotSecure)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    "(!) La contraseña no cumple los requisitos",
                    style: TextStyles.errorMessages(),
                  ),
                ),
              
              // Campo de texto para la confirmación de la contraseña
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  right: 20,
                  left: 20,
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  maxLength: 30,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),

              // Mensaje de error para contraseñas que no coinciden
              if(authProvider.errorPasswordDontMatch)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    "(!) Las contraseñas no coinciden",
                    style: TextStyles.errorMessages(),
                  ),
                ),
              
              // Mensaje de error general
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  textAlign: TextAlign.center,
                  authProvider.errorMessage,
                  style: TextStyles.errorMessages(),
                ),
              ),
            
              // Botón de registro
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  style: ButtonStyles.primaryButton(),
                  child: Text(
                    'Registrarse',
                    style: TextStyles.buttonTexts(),
                  ),
                  onPressed: () async {
                    // Intenta registrar al usuario
                    bool registered = await authProvider.signup(
                      _cedulaController.text,
                      _nameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _confirmPasswordController.text
                    );
                    if (registered) {
                      // Muestra un diálogo de éxito
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Éxito'),
                            content: const Text('Su cuenta ha sido creada'),
                            icon: const Icon(Icons.check),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    setState(() {});
                  },
                ),
              ),
              
              // Botón de cancelar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: ElevatedButton(
                  style: ButtonStyles.primaryButton(backgroundColor: const Color.fromARGB(255, 143, 50, 50)),
                  child: Text(
                    'Cancelar',
                    style: TextStyles.buttonTexts(color: Colors.white),
                  ),
                  onPressed: () {
                    authProvider.clearErrorMessage(); // Limpia el mensaje de error
                    authProvider.clearErrors(); // Limpia los errores
                    Navigator.pushNamed(context, '/login'); // Navega a la página de inicio de sesión
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
