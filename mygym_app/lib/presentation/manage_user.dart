import 'package:flutter/material.dart';
import 'package:mygym_app/providers/local_storage_provider.dart';
import 'package:provider/provider.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/user.dart';
import 'package:mygym_app/providers/user_provider.dart';

class ManageClientPage extends StatefulWidget {
  const ManageClientPage({super.key});

  @override
  State<ManageClientPage> createState() => _ManageClientPageState();
}

class _ManageClientPageState extends State<ManageClientPage> {
  late User currentUser;
  late String currentUserRole;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  bool _confirmed = false;
  bool _blocked = false;
  String errorMessage = "";

  String? _selectedRole; // Nuevo: para almacenar el valor seleccionado del desplegable

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    // Obtener los argumentos pasados a la página
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is User) {
      currentUser = args;
    } else {
      // Si no se proporciona un usuario, crea uno nuevo
      currentUser = User(
        id: "",
        username: '',
        email: '',
        provider: 'local',
        confirmed: false,
        blocked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        cedula: '',
      );
    }

    // Configurar los controladores de texto con los datos del usuario
    _usernameController.text = currentUser.username;
    _emailController.text = currentUser.email;
    _cedulaController.text = currentUser.cedula;
    _confirmed = currentUser.confirmed;
    _blocked = currentUser.blocked;

    _selectedRole = currentUser.role;
  }

  @override
  Widget build(BuildContext context) {
    final localStorageProvider = context.read<LocalStorageProvider>();
    final userProvider = context.read<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 160, 225, 255),
        title: Text(
          "*Null's Gym",
          style: TextStyles.subtitles(
              fontSize: 30, fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentUser.id != "" ? "Modificar Cliente" : "Crear Cliente",
                style: TextStyles.titles(),
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _cedulaController,
                decoration: InputDecoration(
                  labelText: 'Cédula',
                  labelStyle: TextStyles.placeholderForTextFields(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de Usuario',
                  labelStyle: TextStyles.placeholderForTextFields(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    currentUser.username = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  labelStyle: TextStyles.placeholderForTextFields(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    currentUser.email = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Nuevo: Botón desplegable
              DropdownButtonFormField<String>(
                value: _selectedRole,
                hint: const Text("Seleccione un rol"),
                decoration: InputDecoration(
                  labelText: 'Rol',
                  labelStyle: TextStyles.placeholderForTextFields(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _selectedRole = value;
                    currentUser.role = _selectedRole;
                  });
                },
                items: <String>['Administrator', 'Client'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(errorMessage, style: TextStyles.errorMessages()),
              ),

              ElevatedButton(
                style: ButtonStyles.primaryButton(
                  backgroundColor: const Color.fromARGB(255, 0, 96, 131),
                ),
                onPressed: () async {
                  if (currentUser.id == "") {
                    // Crear nuevo usuario
                    if (validateAllInputs()) {
                      bool result = await userProvider.createUser(
                          currentUser,
                          await localStorageProvider.getCurrentUserJWT());

                      if (result) {
                        errorMessage = "";
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Éxito'),
                              content: Text(
                                  'El usuario ${_usernameController.text} ha sido creado correctamente'),
                              icon: const Icon(Icons.check),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  },
                                  child: const Text('Listo'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } else {
                      setState(() {});
                    }
                  } else {
                    // Modificar usuario existente
                    if (validateAllInputs()) {
                      bool result = await userProvider.updateUser(
                          currentUser,
                          await localStorageProvider.getCurrentUserJWT());

                      if (result) {
                        errorMessage = "";
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Éxito'),
                              content: Text(
                                  'El usuario ${_usernameController.text} se ha actualizado'),
                              icon: const Icon(Icons.check),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  },
                                  child: const Text('Listo'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  }
                },
                child: Text(
                  currentUser.id != "" ? "Modificar Cliente" : "Crear Cliente",
                  style: TextStyles.buttonTexts(),
                ),
              ),
              if (currentUser.id != "")

                const SizedBox(height: 20),

              if (currentUser.id != "")
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: ElevatedButton(
                    style: ButtonStyles.primaryButton(
                      backgroundColor: const Color.fromARGB(255, 159, 25, 25),
                    ),
                    onPressed: () async {
                      if (currentUser.id != "" &&
                          await userProvider.deleteUser(
                              currentUser.id,
                              await localStorageProvider
                                  .getCurrentUserJWT())) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Éxito'),
                              content: Text(
                                  'El usuario ${currentUser.username} ha sido eliminado correctamente'),
                              icon: const Icon(Icons.check),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  },
                                  child: const Text('Ok'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        errorMessage = userProvider.errorMessage;
                        setState(() {});
                      }
                    },
                    child: Text(
                      'Borrar Cliente',
                      style: TextStyles.buttonTexts(),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyles.primaryButton(
                  backgroundColor: const Color.fromARGB(255, 0, 96, 131),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  userProvider.clearErrorMessage();
                },
                child: Text(
                  'Volver',
                  style: TextStyles.buttonTexts(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Valida todos los campos de entrada
  bool validateAllInputs() {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _cedulaController.text.isEmpty) {
      errorMessage = "(!) Todos los espacios deben estar completos";
      setState(() {});
      return false;
    }
    
    return true;
  }
}
