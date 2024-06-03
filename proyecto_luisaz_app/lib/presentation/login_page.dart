import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:proyecto_luisaz_app/config/button_styles.dart';
import 'package:proyecto_luisaz_app/config/text_styles.dart';
import 'package:proyecto_luisaz_app/providers/auth_provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    
  }

  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          
              
          
              //Texto de titulo
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 10, color: Colors.black)
                ),
          
                child: const Icon(
                  Icons.sports_martial_arts_rounded,
                  size: 150,
                ),
              ),
          
              Text(
                "*Null's Gym",
                style: TextStyles.titles(),
              ),
          
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  "Iniciar Sesión",
                  style: TextStyles.subtitles(fontSize: 25),
                ),
              ),
              
              //Input de Usuario
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 20,
                  right: 20,
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
          
              //Input de Contraseña
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  right: 20,
                  left: 20,
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
          
              //Mensaje de Error
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  authProvider.errorMessage,
                  style: TextStyles.errorMessages(),
                ),
              ),
              
          
              //Botón de Login
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                
                  style: ButtonStyles.primaryButton(backgroundColor: const Color.fromARGB(255, 11, 135, 75)),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyles.buttonTexts(),
                    
                  ),
                  onPressed: () async {
                    
                    await authProvider.login(
                      _emailController.text,
                      _passwordController.text,
                    );
                    if (authProvider.jwt != null) {
                      Navigator.pushNamed(context, '/home');
                    }
                
                    setState(() {
                      
                    });
                
                  },
                ),
              ),
          
              //Botón de SignUp
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                
                  style: ButtonStyles.primaryButton(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1)),
                  child: Text(
                    'No tienes cuenta? Registrate aquí',
                    style: TextStyles.buttonTexts(fontSize: 15),
                    
                  ),
                  onPressed: () {
                    
                    authProvider.clearErrorMessage();
                    Navigator.pushNamed(context, '/signup');
                
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