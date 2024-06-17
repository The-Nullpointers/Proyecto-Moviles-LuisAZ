import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mygym_app/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Proveedor de usuarios que extiende ChangeNotifier para notificar cambios en los datos a los listeners.
class UserProvider extends ChangeNotifier {
  // URL base de la API, obtenida de variables de entorno.
  final String baseUrl = dotenv.env['BASE_URL']!;
  // Lista interna de usuarios.
  List<User> _users = [];
  // Mensaje de error interno.
  String _errorMessage = '';

  // Getters para acceder a la lista de usuarios y al mensaje de error.
  List<User> get users => _users;
  String get errorMessage => _errorMessage;

  // Método para crear un nuevo usuario.
  Future<bool> createUser(User user, String? jwt) async {
    try {
      // Enviar una solicitud POST para crear un usuario.
      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode(user.toJson()), // Codificar el usuario a JSON.
      );

      // Verificar si la creación fue exitosa.
      if (response.statusCode == 201) {
        _users.add(User.fromJson(jsonDecode(response.body))); // Agregar usuario a la lista.
        notifyListeners(); // Notificar a los listeners.
        return true;
      } else {
        _errorMessage = "Failed to create user: ${response.statusCode}";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to create user: $e";
      notifyListeners();
    }
    return false;
  }

  // Método para obtener el rol de un usuario específico.
  Future<String> getThisUserRole(User user, String? jwt) async {
    try {
      // Enviar una solicitud GET para obtener los detalles del usuario.
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/${user.id}?populate=*'),
        headers: {'Authorization': 'Bearer $jwt'},
      );

      // Verificar si la solicitud fue exitosa.
      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        String roleName = userData['role']['name']; // Obtener el nombre del rol.
        return roleName;
      } else {
        throw Exception('Failed to fetch user role');
      }
    } catch (e) {
      throw Exception('Failed to fetch user role');
    }
  }

  // Método para actualizar un usuario existente.
  Future<bool> updateUser(User user, String? jwt) async {
    try {
      // Enviar una solicitud PUT para actualizar el usuario.
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/${user.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode(user.toJson()), // Codificar el usuario a JSON.
      );

      // Verificar si la actualización fue exitosa.
      if (response.statusCode == 200) {
        // Actualizar la lista interna de usuarios.
        _users = _users.map((u) => u.id == user.id ? User.fromJson(jsonDecode(response.body)) : u).toList();
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to update user: ${response.statusCode}";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to update user: $e";
      notifyListeners();
    }
    return false;
  }

  // Método para eliminar un usuario.
  Future<bool> deleteUser(String id, String? jwt) async {
    try {
      // Enviar una solicitud DELETE para eliminar el usuario.
      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$id'),
        headers: {
          'Authorization': 'Bearer $jwt',
        },
      );

      // Verificar si la eliminación fue exitosa.
      if (response.statusCode == 200) {
        _users.removeWhere((user) => user.id == id); // Remover usuario de la lista.
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to delete user: ${response.statusCode}";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to delete user: $e";
      notifyListeners();
    }
    return false;
  }

  // Método para cargar todos los usuarios.
  Future<void> loadUsers(String? jwt) async {
    try {
      // Enviar una solicitud GET para obtener todos los usuarios.
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Authorization': 'Bearer $jwt',
        },
      );

      // Verificar si la solicitud fue exitosa.
      if (response.statusCode == 200) {
        List<dynamic> usersJson = jsonDecode(response.body);
        _users = usersJson.map((json) => User.fromJson(json)).toList(); // Mapear JSON a lista de usuarios.
        notifyListeners();
      } else {
        _errorMessage = "Failed to load users: ${response.statusCode}";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to load users: $e";
      notifyListeners();
    }
  }

  // Método para limpiar el mensaje de error.
  void clearErrorMessage() {
    _errorMessage = '';
    notifyListeners();
  }
}
