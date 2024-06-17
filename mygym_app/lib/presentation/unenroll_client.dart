import 'package:flutter/material.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/course.dart';
import 'package:mygym_app/models/user.dart';
import 'package:mygym_app/providers/attendance_provider.dart';
import 'package:mygym_app/providers/local_storage_provider.dart';
import 'package:provider/provider.dart';

class UnenrollClientPage extends StatefulWidget {
  const UnenrollClientPage({super.key});

  @override
  State<UnenrollClientPage> createState() => _UnenrollClientPageState();
}

class _UnenrollClientPageState extends State<UnenrollClientPage> {
  late Course currentCourse; // Curso actual seleccionado
  List<User> usersEnrolled = []; // Lista de usuarios inscritos en el curso
  late AttendanceProvider attendanceProvider; // Proveedor de asistencia
  late LocalStorageProvider localStorageProvider; // Proveedor de almacenamiento local
  List<String> items = []; // Lista de ítems para el Dropdown
  late Future<void> fetchFuture; // Future para la carga de datos
  bool isInitialized = false; // Estado de inicialización
  String? selectedItem; // Ítem seleccionado, inicializado como nullable

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      // Obtiene los argumentos de la ruta
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is Course) {
        currentCourse = args; // Asigna el curso actual
      } else {
        // Inicializa un curso vacío si no hay argumentos
        currentCourse = Course(
          id: "",
          name: '',
          capacity: 0,
          schedule: DateTime.now(),
          usersEnrolled: [],
        );
      }

      // Obtiene las instancias de los proveedores
      localStorageProvider = context.read<LocalStorageProvider>();
      attendanceProvider = context.read<AttendanceProvider>();
      // Inicializa el Future para cargar los usuarios e ítems
      fetchFuture = fetchUsersAndItems();
      isInitialized = true; // Marca la página como inicializada
    }
  }

  // Función para cargar los usuarios e ítems
  Future<void> fetchUsersAndItems() async {
    final jwt = await localStorageProvider.getCurrentUserJWT();
    usersEnrolled = await attendanceProvider.getUsersEnrolledInCourse(currentCourse, jwt);

    // Actualiza la lista de ítems para el Dropdown
    setState(() {
      items = usersEnrolled
          .map((user) => "${user.username} - ${user.cedula}")
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String errorMessage = ""; // Mensaje de error
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 160, 225, 255),
        title: Text(
          "*Null's Gym",
          style: TextStyles.subtitles(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        actions: const [],
      ),
      body: FutureBuilder<void>(
        future: fetchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Muestra un indicador de carga
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Muestra un mensaje de error
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dar de baja Cliente",
                    style: TextStyles.titles(fontSize: 35),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentCourse.name,
                    style: TextStyles.titles(),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20, left: 10, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: DropdownButtonFormField<String>(
                            hint: const Text('Seleccionar Cliente'),
                            value: selectedItem,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyles.subtitles(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.blue.shade300,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 12.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedItem = newValue; // Actualiza el ítem seleccionado
                              });
                            },
                            items: items.map<DropdownMenuItem<String>>(
                              (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                                    child: Text(
                                      value,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                            isExpanded: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text(
                      errorMessage,
                      style: TextStyles.errorMessages(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ButtonStyles.primaryButton(
                          backgroundColor: const Color.fromARGB(255, 159, 25, 25),
                        ),
                        onPressed: () async {
                          if (selectedItem != null) {
                            // Intenta dar de baja al cliente seleccionado
                            if (await attendanceProvider.unenrollUserFromCourse(
                                selectedItem!, currentCourse, await localStorageProvider.getCurrentUserJWT())) {
                              // Muestra un diálogo de éxito
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Éxito'),
                                    content: const Text('El cliente ha sido dado de baja'),
                                    icon: const Icon(Icons.check),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop(); // Cierra el diálogo
                                          Navigator.of(context).pop(); // Vuelve a la página anterior
                                        },
                                        child: const Text('Aceptar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } else {
                            errorMessage = "(!) Debe seleccionar un cliente"; // Muestra un mensaje de error
                            setState(() {});
                          }
                        },
                        child: Text(
                          'Dar de Baja',
                          style: TextStyles.buttonTexts(),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyles.primaryButton(
                          backgroundColor: const Color.fromARGB(255, 0, 96, 131),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Vuelve a la página anterior
                        },
                        child: Text(
                          'Volver',
                          style: TextStyles.buttonTexts(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
