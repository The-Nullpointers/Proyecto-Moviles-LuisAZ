// ignore_for_file: empty_catches

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mygym_app/models/course.dart';
import 'package:mygym_app/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mygym_app/providers/course_provider.dart';

class AttendanceProvider extends ChangeNotifier {

  List<Map<User, String?>> attendanceList = [];
  String baseUrl = dotenv.env['BASE_URL']!;

  Future<void> updateUserAttendanceStatus(User user, String? attendanceStatus) async {

    
    
    bool userExists = false;
    int existingIndex = -1;

    for (int i = 0; i < attendanceList.length; i++) {
      if (attendanceList[i].keys.first == user) {
        userExists = true;
        existingIndex = i;
        break;
      }
    }

    if (userExists) {
      attendanceList[existingIndex][user] = attendanceStatus;
    } else {
      attendanceList.add({user: attendanceStatus});
    }
    
  }

  Future<bool> registerConsecutiveAbsences(User user) async {
    return false;
  }

  Future<String?> getUserAttendanceList(User user) async {

    
    for (Map<User, String?> attendanceEntry in attendanceList) {
      User key = attendanceEntry.keys.first;
      if (key == user) {
        return attendanceEntry[key];
      }
    }
    
    return null;
  }

  Future<List<String?>> getUsersAttendanceList(List<User> users) async {
    List<String?> userAttendanceStatusList = [];

    for (User user in users) {
      String? attendanceStatus = 'Ausente'; 

      for (Map<User, String?> attendanceEntry in attendanceList) {
        if (attendanceEntry.keys.first == user) {
          attendanceStatus = attendanceEntry.values.first;
          break;
        }
      }

      userAttendanceStatusList.add(attendanceStatus);
    }

    return userAttendanceStatusList;
  }

  /*Future<void> clearAttendanceList() async {
    attendanceList.clear();
  }*/


  Future<void> setConsecutiveAbsences(User user, Course course, String? jwtToken, CourseProvider courseProvider) async {
    String userCedula = user.cedula;
    String courseId = course.id;

    final url = '$baseUrl/api/attendaces';

    try {
      // Obteniene todos los registros de asistencia
      final response = await http.get(
        Uri.parse('$url?populate=*'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load attendances');
      }

      final attendances = json.decode(response.body)['data'];

      // Busca el registro de asistencia específico
      final attendance = attendances.firstWhere(
        (attendance) =>
            attendance['attributes']['user']['data']['attributes']["cedula"].toString() == userCedula &&
            attendance['attributes']['course']['data']['id'].toString() == courseId,
        orElse: () => null,
      );

      if (attendance == null) {
        throw Exception('Attendance record not found for userId $userCedula and courseId $courseId');
      }

      final attendanceId = attendance['id'];

      // Obteniene los detalles del registro de asistencia específico
      final attendanceResponse = await http.get(
        Uri.parse('$url/$attendanceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (attendanceResponse.statusCode != 200) {
        throw Exception('Failed to load attendance details');
      }

      final attendanceDetails = json.decode(attendanceResponse.body)['data'];
      int consecutiveAbsences = attendanceDetails['attributes']['consecutive_absences'];

      // Incrementa el campo ausencias_consecutivas
      consecutiveAbsences++;

      if(consecutiveAbsences >= 3){
        await courseProvider.unenrollUserFromCourse(user, course, jwtToken);
        
        final updateResponse = await http.delete(
          Uri.parse('$url/$attendanceId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken',
          },
        );

        if (updateResponse.statusCode != 200) {
          throw Exception('Failed to update attendance');
        }

        return;
      }

      // Actualiza el registro de asistencia con las ausencias_consecutivas incrementadas
      final updateResponse = await http.put(
        Uri.parse('$url/$attendanceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({
          'data': {'consecutive_absences': consecutiveAbsences},
        }),
      );



    } catch (e) {
    }
  }

  Future<void> clearConsecutiveAbsences(User user, Course course, String? jwtToken) async {
    String userCedula = user.cedula;
    String courseId = course.id;

    final url = '$baseUrl/api/attendaces';

    try {
      // Obteniene todos los registros de asistencia
      final response = await http.get(
        Uri.parse('$url?populate=*'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load attendances');
      }

      final attendances = json.decode(response.body)['data'];

      // Busca el registro de asistencia específico
      final attendance = attendances.firstWhere(
        (attendance) =>
            attendance['attributes']['user']['data']['attributes']["cedula"].toString() == userCedula &&
            attendance['attributes']['course']['data']['id'].toString() == courseId,
        orElse: () => null,
      );

      if (attendance == null) {
        throw Exception('Attendance record not found for userId $userCedula and courseId $courseId');
      }

      final attendanceId = attendance['id'];

      // Obteniene los detalles del registro de asistencia específico
      final attendanceResponse = await http.get(
        Uri.parse('$url/$attendanceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (attendanceResponse.statusCode != 200) {
        throw Exception('Failed to load attendance details');
      }

      // Actualiza el registro de asistencia con las ausencias_consecutivas incrementadas
      final updateResponse = await http.put(
        Uri.parse('$url/$attendanceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({
          'data': {'consecutive_absences': 0},
        }),
      );

      if (updateResponse.statusCode != 200) {
        throw Exception('Failed to update attendance');
      }

    } catch (e) {
    }
  }

  Future<List<User>> getUsersNotEnrolledInCourse(Course course, String? jwt) async {
    final courseUrl = '$baseUrl/api/courses/${course.id}?populate=*';
    final usersUrl = '$baseUrl/api/users';

    try {
      // Obtiene los detalles del curso
      final courseResponse = await http.get(
        Uri.parse(courseUrl),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (courseResponse.statusCode != 200) {
        throw Exception('Failed to load course details');
      }

      final courseData = json.decode(courseResponse.body)['data']['attributes'];
      final courseUsersData = courseData['users']['data'] as List;
      final List<String> courseUserIds = courseUsersData.map((user) => user["attributes"]['cedula'] as String).toList();

      // Obtiene todos los usuarios
      final usersResponse = await http.get(
        Uri.parse(usersUrl),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (usersResponse.statusCode != 200) {
        throw Exception('Failed to load users');
      }

      final allUsersData = json.decode(usersResponse.body) as List;
      List<User> allUsers = allUsersData.map((userJson) => User.fromJson(userJson)).toList();

      // Filtra los usuarios ya inscritos en el curso
      List<User> usersNotInCourse = allUsers.where((user) => !courseUserIds.contains(user.cedula)).toList();

      for(var user in usersNotInCourse){
      }

      return usersNotInCourse;
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> getAllUsers(String? jwt) async {
    final usersUrl = '$baseUrl/api/users';

    try {
      
      // Obtiene todos los usuarios
      final usersResponse = await http.get(
        Uri.parse(usersUrl),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (usersResponse.statusCode != 200) {
        throw Exception('Failed to load users');
      }

      final allUsersData = json.decode(usersResponse.body) as List;
      List<User> allUsers = allUsersData.map((userJson) => User.fromJson(userJson)).toList();

      return allUsers;
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> getUsersEnrolledInCourse(Course course, String? jwt) async {
    final courseUrl = '$baseUrl/api/courses/${course.id}?populate=*';
    final usersUrl = '$baseUrl/api/users';

    try {
      // Obtiene los detalles del curso
      final courseResponse = await http.get(
        Uri.parse(courseUrl),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (courseResponse.statusCode != 200) {
        throw Exception('Failed to load course details');
      }

      final courseData = json.decode(courseResponse.body)['data']['attributes'];
      final courseUsersData = courseData['users']['data'] as List;
      final List<String> courseUserIds = courseUsersData.map((user) => user["attributes"]['cedula'] as String).toList();

      // Obtiene todos los usuarios
      final usersResponse = await http.get(
        Uri.parse(usersUrl),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (usersResponse.statusCode != 200) {
        throw Exception('Failed to load users');
      }

      final allUsersData = json.decode(usersResponse.body) as List;
      List<User> allUsers = allUsersData.map((userJson) => User.fromJson(userJson)).toList();

      // Filtra los usuarios ya inscritos en el curso
      List<User> usersNotInCourse = allUsers.where((user) => courseUserIds.contains(user.cedula)).toList();

      for(var user in usersNotInCourse){
      }

      return usersNotInCourse;
    } catch (e) {
      return [];
    }
  }

  


  


  Future<bool> enrollClient(String selectedItem, Course course, String? jwt) async {
    // Divide el elemento seleccionado para extraer la cédula
    List<String> parts = selectedItem.split(' - ');
    
    if (parts.length < 2) {
      return false;
    }

    String cedula = parts[1];

    // Obt el ID de usuario mediante cédula
    String userId = await fetchUserIdByCedula(cedula, jwt!);
    if (userId == null) {
      return false;
    }

    // Inscribe al usuario en el

    final url = Uri.parse('$baseUrl/api/courses/${course.id}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt',
    };
    final body = jsonEncode({
      'data': {
        'users': {
          'connect': [{'id': userId}]
        }
      }
    });

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Crea un registro de asistencia
        await createAttendance(userId, course.id, jwt);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }



  Future<void> createAttendance(String userId, String courseId, String jwt) async {

    final url = Uri.parse('$baseUrl/api/attendaces');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt',
    };

    int userIdInt = int.parse(courseId);
    int courseIdInt = int.parse(userId);


    final body = jsonEncode({
      'data': {
        'course': {
          'connect': [{'id': userIdInt}]
        },
        'user': {
          'connect': [{'id': courseIdInt}]
        }
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
    }
  }
  
  Future<bool> unenrollClient(String selectedItem, Course course, String? jwt) async {
    try {
      List<String> parts = selectedItem.split(' - ');
    
      if (parts.length < 2) {
      return false;
      }
    // Obtiene al usuario según el ID de la cédula
    String userCedula = parts[1];
      String userId = await fetchUserIdByCedula(userCedula, jwt!);

      // Elimina el usuario de la colección de usuarios del curso
      bool userDisconnected = await disconnectUserFromCourse(userId, course.id, jwt);
      if (!userDisconnected) {
        return false;
      }

      // Elimina la línea de asistencia
      bool attendanceDeleted = await deleteAttendance(userId, course.id, jwt);
      if (!attendanceDeleted) {
      }

      // Devuelve true si ambas operaciones se han realizado correctamente
      return userDisconnected && attendanceDeleted;
    } catch (e) {
      return false;
    }
  }

  Future<String> fetchUserIdByCedula(String cedula, String jwt) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: <String, String>{
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);


        for (var user in jsonResponse) {
          if (user['cedula'] == cedula) {
            return user['id'].toString();
          }
        }

        throw Exception('User with cedula $cedula not found');
      } else {
        throw Exception('Failed to fetch user ID');
      }
    } catch (e) {
      return "";
    }
  }

  Future<bool> disconnectUserFromCourse(String userId, String courseId, String jwt) async {
    try {
      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'data': {
          'users': {
            'disconnect': [{'id': userId}]
          }
        }
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/courses/$courseId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to disconnect user from course: ${response.statusCode}');
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAttendance(String userId, String courseId, String jwt) async {
    int userIdInt = int.parse(userId);
    int courseIdInt = int.parse(courseId);


    try {
      // Obtiene los registros de asistencia
      final response = await http.get(
        Uri.parse('$baseUrl/api/attendaces?populate=*'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch attendance records: ${response.statusCode}');
      }

      // Parse the response body
      final data = jsonDecode(response.body);
      final List attendances = data['data'];

      // Find the attendance record that matches the userId and courseId
      final attendance = attendances.firstWhere(
        (attendance) =>
            attendance['attributes']['user']['data']['id'] == userIdInt &&
            attendance['attributes']['course']['data']['id'] == courseIdInt,
        orElse: () => null,
      );

      if (attendance == null) {
        throw Exception('No matching attendance record found');
      }

      final int attendanceId = attendance['id'];

      // Delete the attendance record
      final deleteResponse = await http.delete(
        Uri.parse('$baseUrl/api/attendaces/$attendanceId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (deleteResponse.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete attendance: ${deleteResponse.statusCode}');
      }
    } catch (e) {
      return false;
    }
  }



}