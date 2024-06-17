import 'package:flutter/material.dart';
import 'package:mygym_app/models/user.dart';
import 'package:mygym_app/providers/attendance_provider.dart';
import 'package:mygym_app/providers/user_provider.dart';
import 'package:mygym_app/widgets/client_card.dart';
import 'package:provider/provider.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/providers/course_provider.dart';
import 'package:mygym_app/providers/local_storage_provider.dart';

class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  String? currentUserRole; // Variable para almacenar el rol del usuario actual
  String? currentUserUsername; // Variable para almacenar el nombre de usuario actual
  List<User> users = []; // Lista de usuarios
  late ScrollController _scrollController; // Controlador para el scroll
  bool isLoading = true; // Bandera para indicar si los datos están cargando

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Obtener datos cuando el widget se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    // Obtener los proveedores necesarios
    final localStorageProvider = context.read<LocalStorageProvider>();
    final courseProvider = context.read<CourseProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final userProvider = context.read<UserProvider>();

    try {
      // Obtener datos del almacenamiento local y otros proveedores
      currentUserRole = await localStorageProvider.getCurrentUserRole();
      currentUserUsername = await localStorageProvider.getCurrentUserUsername();
      await courseProvider.loadcurrentUserEnrolledCoursesList();
      users = await attendanceProvider.getAllUsers(await localStorageProvider.getCurrentUserJWT());
      for (var user in users) {
        user.role = await userProvider.getThisUserRole(user, await localStorageProvider.getCurrentUserJWT());
      }
      // Actualizar el estado una vez que los datos se han obtenido
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              setState(() {
                isLoading = true;
              });
              await fetchData();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 20,
                        left: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Panel de Usuarios\nUsuario: $currentUserUsername",
                          style: TextStyles.subtitles(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 600,
                      width: 400,
                      // Lista de Clientes
                      child: Consumer<CourseProvider>(
                        builder: (context, courseProvider, child) {
                          // Asegurarse de que las longitudes de los datos coincidan
                          return Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return ClientCard(user: user);
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
                                backgroundColor: const Color.fromARGB(255, 0, 96, 131),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Volver',
                                style: TextStyles.buttonTexts(
                                    color: Colors.white, fontWeight: FontWeight.bold),
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
  }
}