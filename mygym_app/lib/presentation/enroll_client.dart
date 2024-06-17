import 'package:flutter/material.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/course.dart';
import 'package:mygym_app/models/user.dart';
import 'package:mygym_app/providers/attendance_provider.dart';
import 'package:mygym_app/providers/auth_provider.dart';
import 'package:mygym_app/providers/local_storage_provider.dart';
import 'package:provider/provider.dart';

class EnrollClientPage extends StatefulWidget {
  const EnrollClientPage({super.key});

  @override
  State<EnrollClientPage> createState() => _EnrollClientPageState();
}

class _EnrollClientPageState extends State<EnrollClientPage> {
  late Course currentCourse;
  List<User> usersNotEnrrolled = [];
  late AttendanceProvider attendanceProvider;
  late LocalStorageProvider localStorageProvider;
  List<String> items = [];
  late Future<void> fetchFuture;
  bool isInitialized = false;
  String? selectedItem; // Initialize selectedItem as nullable

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is Course) {
        currentCourse = args;
      } else {
        currentCourse = Course(
          id: "",
          name: '',
          capacity: 0,
          schedule: DateTime.now(),
          usersEnrolled: [],
        );
      }

      localStorageProvider = context.read<LocalStorageProvider>();
      attendanceProvider = context.read<AttendanceProvider>();
      fetchFuture = fetchUsersAndItems();
      isInitialized = true;
    }
  }

  Future<void> fetchUsersAndItems() async {
    final jwt = await localStorageProvider.getCurrentUserJWT();
    usersNotEnrrolled = await attendanceProvider.getUsersNotEnrolledInCourse(currentCourse, jwt);
    

    setState(() {
      items = usersNotEnrrolled
          .map((user) => "${user.username} - ${user.cedula}")
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    String errorMessage = "";
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Matricular Cliente",
                    style: TextStyles.titles(fontSize: 35),
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    currentCourse.name,
                    style: TextStyles.titles(),
                  ),
                  const SizedBox(height: 10,),
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
                                selectedItem = newValue;
                                print("ITEM CHANGE: $selectedItem");
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
                          backgroundColor: const Color.fromARGB(255, 41, 177, 14),
                        ),
                        onPressed: () async {
                          print("GUARDAR");
                          if(selectedItem != null){

                          
                            if (await attendanceProvider.enrollClient(selectedItem!, currentCourse, await localStorageProvider.getCurrentUserJWT())) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Éxito'),
                                    content: const Text('El cliente ha sido matriculado'),
                                    icon: const Icon(Icons.check),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Aceptar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } else {
                            errorMessage = "(!) Debe seleccionar un cliente";
                            setState(() {});
                          }
                        },
                        child: Text(
                          'Matricular',
                          style: TextStyles.buttonTexts(),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyles.primaryButton(
                          backgroundColor: const Color.fromARGB(255, 0, 96, 131),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
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
