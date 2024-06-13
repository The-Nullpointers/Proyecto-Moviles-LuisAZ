import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:proyecto_luisaz_app/models/current_user.dart';
import 'dart:convert';

import 'package:proyecto_luisaz_app/providers/local_storage_provider.dart';

class AuthProvider with ChangeNotifier {

  late LocalStorageProvider localStorageProvider;

  final CurrentUser? currentUser = null;

  bool _errorEmptyFields = false;
  bool _errorCedula = false;
  bool _errorEmail = false;
  bool _errorPasswordNotSecure = false;
  bool _errorPasswordDontMatch = false;

  String _customErrorMessage = "";

  String baseUrl = dotenv.env['BASE_URL']!;
  bool _isLoading = false;
  String _errorMessage = '';
  String? _jwt;
  String? _userId;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get jwt => _jwt;
  String? get userId => _userId;
  String get customErrorMessage => _customErrorMessage;

  bool get errorEmptyFields => _errorEmptyFields;
  bool get errorCedula => _errorCedula;
  bool get errorEmail => _errorEmail;
  bool get errorPasswordNotSecure => _errorPasswordNotSecure;
  bool get errorPasswordDontMatch => _errorPasswordDontMatch;

  void setLocalStorageProvider(LocalStorageProvider x){
    localStorageProvider = x;
  }

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

  bool isThisPasswordSecure(String password) {
    String pattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,30}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }

  Future<bool> signup(String cedula, String name, String email, String password, String confirmPassword) async {

    _customErrorMessage = "";
    if(cedula.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty){
      _errorEmptyFields = true;
    } else { _errorEmptyFields = false; }

    if(!isThisEmailValid(email)){
      _errorEmail = true;
    } else { _errorEmail = false; }

    if(cedula.length != 9 && cedula.length != 12){
      _errorCedula = true;
    } else { _errorCedula = false; }

    if(password != confirmPassword){
      _errorPasswordDontMatch = true;
    } else { _errorPasswordDontMatch = false; }

    if(!isThisPasswordSecure(password)){
      _errorPasswordNotSecure = true;
    } else { _errorPasswordNotSecure = false; }

    if(_errorCedula || _errorEmail || _errorEmptyFields || _errorPasswordDontMatch || _errorPasswordNotSecure){
      notifyListeners();
      return false;
    }

    final url = Uri.parse('$baseUrl/api/auth/local/register');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "username": name,
      "email": email,
      "password": password,
      "cedula": cedula
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        _customErrorMessage = responseData['error']['message'];
      }

      return false; 
    } catch (e) {
      return false; 
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

      //Login exitoso
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        _jwt = responseBody['jwt'];

        await saveCurrentUserData(jwt);



      } else {
        _errorMessage = '(!) Los credenciales no son correctos';
      }
    } catch (e) {
      _errorMessage = 'Exception occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCurrentUserData(String? jwt) async {
    
    final url = Uri.parse('$baseUrl/api/users/me?populate=role');

    try {

      print("JWT: $jwt");
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwt',
        },
      );

      
      if (response.statusCode == 200) {
            
        final Map<String, dynamic> userData = json.decode(response.body);

        await localStorageProvider.saveCurrentUserData(userData, jwt);
                
      } else {
        
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      
      throw Exception('Failed to load user data: $e');
    }
  }


  Future<void> logout() async{
    await localStorageProvider.logoutCurrentUser();
    _jwt = null;
  }



}
