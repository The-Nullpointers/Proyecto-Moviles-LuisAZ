import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/providers/auth_provider.dart';
import 'package:mygym_app/providers/course_provider.dart';
import 'package:mygym_app/providers/local_storage_provider.dart';
import 'package:mygym_app/widgets/client_course_card.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  String? currentUserRole; // Variable para almacenar el rol del usuario actual
  String? currentUserUsername; // Variable para almacenar el nombre de usuario actual
  late ScrollController _scrollController; // Controlador para el scroll

  @override
  void initState() {
    _scrollController = ScrollController();
    final localStorageProvider = context.read<LocalStorageProvider>();
    final courseProvider = context.read<CourseProvider>();
    courseProvider.setLocalStorageProvider(localStorageProvider);

    super.initState();   
  }

  Future<void> getCurrentUserData(LocalStorageProvider localStorageProvider, CourseProvider courseProvider) async {
    // Obtener el rol y nombre de usuario actual desde el almacenamiento local
    currentUserRole = await localStorageProvider.getCurrentUserRole();
    currentUserUsername = await localStorageProvider.getCurrentUserUsername();
    // Cargar la lista de cursos en los que el usuario está inscrito
    await courseProvider.loadcurrentUserEnrolledCoursesList();
  }

  @override
  Widget build(BuildContext context) {
    // Proveedores ---------------------------------------------
    final authProvider = context.read<AuthProvider>();
    final localStorageProvider = context.read<LocalStorageProvider>();
    final courseProvider = context.read<CourseProvider>();
    // Proveedores ---------------------------------------------

    return FutureBuilder(
      future: getCurrentUserData(localStorageProvider, courseProvider),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 160, 225, 255),
            title: Text(
              "*Null's Gym",
              style: TextStyles.subtitles(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      bottom: 20,
                      left: 20
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Bienvenido, $currentUserUsername!",
                        style: TextStyles.subtitles(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 600,
                    width: 400,
                    // Lista de Cursos
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true, 
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: courseProvider.currentUserEnrolledCourses.length,
                        itemBuilder: (context, index) {
                          final course = courseProvider.currentUserEnrolledCourses[index];
                          return ClientCourseCard(course: course);
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20,),
                        child: ElevatedButton(
                          style: ButtonStyles.primaryButton(
                            backgroundColor: const Color.fromARGB(255, 0, 96, 131),
                          ),
                          onPressed: () async {
                            // Refrescar la lista de cursos en los que el usuario está inscrito
                            await courseProvider.loadcurrentUserEnrolledCoursesList();
                            setState(() {});
                          },
                          child: Text(
                            'Refrescar Cursos',
                            style: TextStyles.buttonTexts(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20,),
                        child: ElevatedButton(
                          style: ButtonStyles.primaryButton(
                            backgroundColor: const Color.fromARGB(255, 237, 59, 19),
                          ),
                          onPressed: () async {
                            // Cerrar sesión
                            await authProvider.logout();
                            if (authProvider.jwt == null) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          child: Text(
                            'Cerrar Sesión',
                            style: TextStyles.buttonTexts(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}