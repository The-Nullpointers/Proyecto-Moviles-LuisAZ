import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'dart:convert';

class AuthProvider with ChangeNotifier {

  bool _errorEmptyFields = false;
  bool _errorCedula = false;
  bool _errorEmail = false;
  bool _errorPasswordNotSecure = false;
  bool _errorPasswordDontMatch = false;

  String baseUrl = dotenv.env['BASE_URL']!;
  bool _isLoading = false;
  String _errorMessage = '';
  String? _jwt;
  String? _userId;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get jwt => _jwt;
  String? get userId => _userId;
  bool get errorEmptyFields => _errorEmptyFields;
  bool get errorCedula => _errorCedula;
  bool get errorEmail => _errorEmail;
  bool get errorPasswordNotSecure => _errorPasswordNotSecure;
  bool get errorPasswordDontMatch => _errorPasswordDontMatch;

  void clearErrorMessage(){
    _errorMessage = "";
  }

  void clearErrors(){
    _errorEmptyFields = false;
    _errorCedula = false;
    _errorEmail = false;
    _errorPasswordNotSecure = false;
    _errorPasswordDontMatch = false;
  }

  
  bool isThisEmailValid(String email) {
    final emailCheck = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailCheck.hasMatch(email);
  }

  Future<void> signup(String cedula, String email, String password, String confirmPassword) async {

    if(cedula.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty){
      _errorEmptyFields = true;
    } else { _errorEmptyFields = false; }

    if(!isThisEmailValid(email)){
      _errorEmail = true;
    } else { _errorEmail = false; }

    if(cedula.length != 9 && cedula.length != 15){
      _errorCedula = true;
    } else { _errorCedula = false; }

    if(password != confirmPassword){
      _errorPasswordDontMatch = true;
    } else { _errorPasswordDontMatch = false; }




    if(_errorCedula || _errorEmail || _errorEmptyFields || _errorPasswordDontMatch || _errorPasswordNotSecure){
      notifyListeners();
      return;
    }

  }

  Future<void> login(String email, String password) async {

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = '(!) Se requiere de usuario y contraseña.';
      notifyListeners();
      return;
    }

    if(!isThisEmailValid(email)){
      _errorMessage = "(!) Dirección de correo no válida";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/local'), 
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'identifier': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        _jwt = responseBody['jwt'];
        _userId = responseBody['user']['id'].toString();
        _errorMessage = 'Login successful';
      } else {
        _errorMessage = 'Login failed: ${response.body}';
      }
    } catch (e) {
      _errorMessage = 'Exception occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
