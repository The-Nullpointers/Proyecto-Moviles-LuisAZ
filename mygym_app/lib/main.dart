import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mygym_app/presentation/client_list_page.dart';
import 'package:mygym_app/presentation/enroll_client.dart';
import 'package:mygym_app/presentation/manage_user.dart';
import 'package:mygym_app/presentation/unenroll_client.dart';
import 'package:mygym_app/providers/attendance_provider.dart';
import 'package:mygym_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:mygym_app/presentation/admin_page.dart';
import 'package:mygym_app/presentation/client_page.dart';
import 'package:mygym_app/presentation/course_clients_page.dart';
import 'package:mygym_app/presentation/login_page.dart';
import 'package:mygym_app/presentation/manage_course.dart';
import 'package:mygym_app/presentation/sign_up_page.dart';
import 'package:mygym_app/providers/auth_provider.dart';
import 'package:mygym_app/providers/course_provider.dart';
import 'package:mygym_app/providers/local_storage_provider.dart';

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
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        
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
          '/manageClient': (context) => const ManageClientPage(),
          '/usersEnrolledCourse': (context) => const CourseClientsPage(),
          '/enrollClient': (context) => const EnrollClientPage(),
          '/unenrollClient': (context) => const UnenrollClientPage(),
          '/clientList': (context) => const ClientListPage(),
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
