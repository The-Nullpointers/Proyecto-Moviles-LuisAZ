import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mygym_app/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserProvider extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL']!; // Ensure you have set BASE_URL in your .env file
  List<User> _users = [];
  String _errorMessage = '';

  List<User> get users => _users;
  String get errorMessage => _errorMessage;

  Future<bool> createUser(User user, String? jwt) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        print('User created successfully');
        _users.add(User.fromJson(jsonDecode(response.body)));
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to create user: ${response.statusCode}";
        print('Failed to create user: ${response.statusCode}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to create user: $e";
      print('Failed to create user: $e');
      notifyListeners();
    }
    return false;
  }

  Future<String> getThisUserRole(User user, String? jwt) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/${user.id}?populate=*'),
        headers: {'Authorization': 'Bearer $jwt'},
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        Map<String, dynamic> userData = jsonDecode(response.body);

        // Extract the role name
        String roleName = userData['role']['name'];

        return roleName;
      } else {
        // Handle other status codes if needed
        throw Exception('Failed to fetch user role');
      }
    } catch (e) {
      // Handle errors
      print('Error in fetching user role: $e');
      throw Exception('Failed to fetch user role');
    }
  }

  Future<bool> updateUser(User user, String? jwt) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/${user.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        print('User updated successfully');
        _users = _users.map((u) => u.id == user.id ? User.fromJson(jsonDecode(response.body)) : u).toList();
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to update user: ${response.statusCode}";
        print('Failed to update user: ${response.statusCode}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to update user: $e";
      print('Failed to update user: $e');
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteUser(String id, String? jwt) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$id'),
        headers: {
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        print('User deleted successfully');
        _users.removeWhere((user) => user.id == id);
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to delete user: ${response.statusCode}";
        print('Failed to delete user: ${response.statusCode}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to delete user: $e";
      print('Failed to delete user: $e');
      notifyListeners();
    }
    return false;
  }

  Future<void> loadUsers(String? jwt) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        print('Users loaded successfully');
        List<dynamic> usersJson = jsonDecode(response.body);
        _users = usersJson.map((json) => User.fromJson(json)).toList();
        notifyListeners();
      } else {
        _errorMessage = "Failed to load users: ${response.statusCode}";
        print('Failed to load users: ${response.statusCode}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to load users: $e";
      print('Failed to load users: $e');
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    _errorMessage = '';
    notifyListeners();
  }
}
