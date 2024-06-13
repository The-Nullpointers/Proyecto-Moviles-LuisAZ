import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_luisaz_app/presentation/admin_page.dart';
import 'package:proyecto_luisaz_app/presentation/client_page.dart';
import 'package:proyecto_luisaz_app/presentation/login_page.dart';
import 'package:proyecto_luisaz_app/presentation/manage_course.dart';
import 'package:proyecto_luisaz_app/presentation/sign_up_page.dart';
import 'package:proyecto_luisaz_app/providers/auth_provider.dart';
import 'package:proyecto_luisaz_app/providers/course_provider.dart';
import 'package:proyecto_luisaz_app/providers/local_storage_provider.dart';

// Null Pointer's Gym App
// Luis Andrés Aguilar Bolaños
// Luis David Zeledón Gómez

void main() async {
  await dotenv.load(fileName: ".env"); // Duré 2 horas dando vueltas porque el provider no quería servir sin esta línea
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(

      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocalStorageProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
      ],

      child: MaterialApp(
        title: '*Null Gym',
        debugShowCheckedModeBanner: false,

        //Declara rutas para luego facilitar la navegacion mediante botones
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/homeClient': (context) => const ClientPage(),
          '/homeAdmin': (context) => const AdminPage(),
          '/manageCourse': (context) => const ManageCoursePage(),
        },

        theme: ThemeData(
        
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
          useMaterial3: true,
        ),

        home: const LoginPage(),
      )
    );
  }
}
