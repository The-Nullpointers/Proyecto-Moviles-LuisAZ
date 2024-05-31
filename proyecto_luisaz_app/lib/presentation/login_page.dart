import 'package:flutter/material.dart';
import 'package:proyecto_luisaz_app/config/text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  String _errorMessage = "";
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  bool _validateInput() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = '(!) Se requiere de usuario y contraseña.';
      });

      return false;
    } else {

      setState(() {
        _errorMessage = "";
      });
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            

            //Texto de titulo
            Container(
              padding: EdgeInsets.all(10),
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
            
            //Input de Usuario
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Cédula de Usuario',
                  labelStyle: TextStyles.placeholderForTextFields(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),

            //Input de Contraseña
            Padding(
              padding: const EdgeInsets.all(20.0),
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
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _errorMessage,
                style: TextStyles.errorMessages(),
              ),
            ),
            

            //Botón de Login
            ElevatedButton(

              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Colors.lightBlueAccent,
                

              ),
              child: Text(
                'Iniciar Sesión',
                style: TextStyles.buttonTexts(),
                
              ),
              onPressed: () {
                
                if(_validateInput()){ //Si existe texto en ambos inputs, reinicia el texto y tira al HomeScreen
                  _usernameController.text = "";
                  _passwordController.text = "";

                  Navigator.pushNamed(context, '/homeScreen');
                }

              },
            ),

          ],
        ),
      ),
    );
  }
}