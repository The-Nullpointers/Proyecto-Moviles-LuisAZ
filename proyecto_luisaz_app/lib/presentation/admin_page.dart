import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_luisaz_app/config/button_styles.dart';
import 'package:proyecto_luisaz_app/config/text_styles.dart';
import 'package:proyecto_luisaz_app/providers/auth_provider.dart';
import 'package:proyecto_luisaz_app/providers/course_provider.dart';
import 'package:proyecto_luisaz_app/providers/local_storage_provider.dart';
import 'package:proyecto_luisaz_app/widgets/admin_course_card.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  String? currentUserRole;
  String? currentUserUsername;
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    final localStorageProvider = context.read<LocalStorageProvider>();
    final courseProvider = context.read<CourseProvider>();
    courseProvider.setLocalStorageProvider(localStorageProvider);

    super.initState();   
  }

  Future<void> getCurrentUserData(LocalStorageProvider localStorageProvider, CourseProvider courseProvider) async {
    currentUserRole = await localStorageProvider.getCurrentUserRole();
    currentUserUsername = await localStorageProvider.getCurrentUserUsername();
    await courseProvider.loadcurrentUserEnrolledCoursesList();
  }

  @override
  Widget build(BuildContext context) {

    // Providers ---------------------------------------------
    final authProvider = context.read<AuthProvider>();
    final localStorageProvider = context.read<LocalStorageProvider>();
    final courseProvider = context.read<CourseProvider>();
    // Providers ---------------------------------------------

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
                        "Panel de Administración\nUsuario: $currentUserUsername",
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
                          return AdminCourseCard(course: course);
                        },
                      ),
                    ),
                  ),


                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 20,),
                        child: ElevatedButton(
                          style: ButtonStyles.primaryButton(
                            backgroundColor: Color.fromARGB(255, 0, 96, 131),
                          ),
                          onPressed: () async {
                            await courseProvider.loadcurrentUserEnrolledCoursesList();
                      
                            setState(() {
                              
                            });
                          },
                          child: Text(
                            'Refrescar Cursos',
                            style: TextStyles.buttonTexts(),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 20,),
                        child: ElevatedButton(
                          style: ButtonStyles.primaryButton(
                            backgroundColor: Color.fromARGB(255, 237, 59, 19),
                          ),
                          onPressed: () async {
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
