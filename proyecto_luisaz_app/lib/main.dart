import 'package:flutter/material.dart';
import 'package:proyecto_luisaz_app/presentation/home_page.dart';
import 'package:proyecto_luisaz_app/presentation/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '*Null Gym',
      debugShowCheckedModeBanner: false,

      //Declara rutas para luego facilitar la navegacion mediante botones
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },

      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),

      home: const LoginPage(),
    );
  }
}
