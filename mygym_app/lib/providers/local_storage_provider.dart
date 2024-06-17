import 'package:flutter/material.dart';
import 'package:mygym_app/providers/auth_provider.dart';
import 'package:mygym_app/services/local_database.dart';

// Proveedor de almacenamiento local que extiende ChangeNotifier para notificar cambios en los datos a los listeners.
class LocalStorageProvider extends ChangeNotifier {
  // Instancia de AuthProvider que se configurará más tarde.
  late AuthProvider authProvider;
  // Instancia de la base de datos local.
  final LocalDatabase localDatabase = LocalDatabase();

  // Método para configurar el AuthProvider.
  void setAuthProvider(AuthProvider x) {
    localDatabase.setAuthProvider(x); // Configura AuthProvider en la base de datos local.
  }

  // Método para guardar los datos actuales del usuario en la base de datos local.
  Future<void> saveCurrentUserData(Map<String, dynamic> data, String? jwt) async {
    await localDatabase.saveCurrentUserData(data, jwt); // Guarda los datos del usuario junto con el JWT.
  }

  // Método para obtener el JWT del usuario actual desde la base de datos local.
  Future<String?> getCurrentUserJWT() async {
    return await localDatabase.getCurrentUserJWT(); // Retorna el JWT del usuario actual.
  }

  // Método para cerrar la sesión del usuario actual.
  Future<void> logoutCurrentUser() async {
    await localDatabase.logout(); // Elimina la información del usuario de la base de datos local.
  }

  // Método para obtener el nombre de usuario del usuario actual desde la base de datos local.
  Future<String?> getCurrentUserUsername() async {
    return await localDatabase.getCurrentUserUsername(); // Retorna el nombre de usuario del usuario actual.
  }

  // Método para obtener el rol del usuario actual desde la base de datos local.
  Future<String?> getCurrentUserRole() async {
    return await localDatabase.getCurrentUserRole(); // Retorna el rol del usuario actual.
  }
}
