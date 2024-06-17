import 'package:flutter/material.dart';
import 'package:mygym_app/models/course.dart';
import 'package:provider/provider.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/providers/auth_provider.dart';
import 'package:mygym_app/providers/course_provider.dart';
import 'package:mygym_app/providers/local_storage_provider.dart';
import 'package:mygym_app/widgets/admin_course_card.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
    // Obtener datos del almacenamiento local
    currentUserRole = await localStorageProvider.getCurrentUserRole();
    currentUserUsername = await localStorageProvider.getCurrentUserUsername();
    await courseProvider.loadcurrentUserEnrolledCoursesList();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener proveedores
    final authProvider = context.read<AuthProvider>();
    final localStorageProvider = context.read<LocalStorageProvider>();
    final courseProvider = context.read<CourseProvider>();

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
                onPressed: () async {
                  await courseProvider.loadcurrentUserEnrolledCoursesList();
                  setState(() {});
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (authProvider.jwt == null) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                icon: const Icon(Icons.logout),
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
                        "Panel de Administración\nUsuario: $currentUserUsername",
                        style: TextStyles.subtitles(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 600,
                    width: 400,
                    // Lista de Cursos
                    child: Consumer<CourseProvider>(
                      builder: (context, courseProvider, child) {
                        return Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true, 
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: courseProvider.currentUserEnrolledCourses.length,
                            itemBuilder: (context, index) {
                              final course = courseProvider.currentUserEnrolledCourses[index];
                              return AdminCourseCard(course: course);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          child: ElevatedButton(
                            style: ButtonStyles.primaryButton(
                              backgroundColor: const Color.fromARGB(255, 23, 245, 138),
                            ),
                            onPressed: () async {
                              // Crear un nuevo curso vacío
                              Course currentCourse = Course(
                                id: "",
                                name: '',
                                capacity: 0,
                                schedule: DateTime.now(),
                                usersEnrolled: [],
                              );
                              // Navegar a la página de gestión de curso
                              Navigator.pushNamed(context, '/manageCourse', arguments: currentCourse);
                            },
                            child: Text(
                              'Nuevo Curso',
                              style: TextStyles.buttonTexts(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          child: ElevatedButton(
                            style: ButtonStyles.primaryButton(
                              backgroundColor: const Color.fromARGB(255, 0, 96, 131)
                            ),
                            onPressed: () async {
                              // Navegar a la página de lista de clientes
                              Navigator.pushNamed(context, '/clientList');
                            },
                            child: Text(
                              'Ver Clientes',
                              style: TextStyles.buttonTexts(color: Colors.white, fontWeight: FontWeight.bold),
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
        );
      },
    );
  }
}