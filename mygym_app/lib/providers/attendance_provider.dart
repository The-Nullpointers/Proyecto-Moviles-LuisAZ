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

  Future<void> setConsecutiveAbsences(User user, Course course, String? jwtToken, CourseProvider courseProvider) async {
    String userCedula = user.cedula;
    String courseId = course.id;

    final url = '$baseUrl/api/attendaces';

    try {
      // Paso 1: Obtener todos los registros de asistencia
      final response = await http.get(
        Uri.parse('$url?populate=*'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cargar las asistencias');
      }

      final attendances = json.decode(response.body)['data'];

      // Paso 2: Encontrar el registro de asistencia específico
      final attendance = attendances.firstWhere(
        (attendance) =>
            attendance['attributes']['user']['data']['attributes']["cedula"].toString() == userCedula &&
            attendance['attributes']['course']['data']['id'].toString() == courseId,
        orElse: () => null,
      );

      if (attendance == null) {
        throw Exception('Registro de asistencia no encontrado para userId $userCedula y courseId $courseId');
      }

      final attendanceId = attendance['id'];

      // Paso 3: Obtener los detalles del registro de asistencia específico
      final attendanceResponse = await http.get(
        Uri.parse('$url/$attendanceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (attendanceResponse.statusCode != 200) {
        throw Exception('Error al cargar los detalles de asistencia');
      }

      final attendanceDetails = json.decode(attendanceResponse.body)['data'];
      int consecutiveAbsences = attendanceDetails['attributes']['consecutive_absences'];

      // Paso 4: Incrementar el campo de ausencias consecutivas
      consecutiveAbsences++;

      if (consecutiveAbsences >= 3) {
        await courseProvider.unenrollUserFromCourse(user, course, jwtToken);
        
        final updateResponse = await http.delete(
          Uri.parse('$url/$attendanceId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken',
          },
        );

        if (updateResponse.statusCode != 200) {
          throw Exception('Error al actualizar la asistencia');
        }

        return;
      }

      // Paso 5: Actualizar el registro de asistencia con las ausencias consecutivas incrementadas
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
      // ignorar
    }
  }

  Future<void> clearConsecutiveAbsences(User user, Course course, String? jwtToken) async {
    String userCedula = user.cedula;
    String courseId = course.id;

    final url = '$baseUrl/api/attendaces';

    try {
      // Paso 1: Obtener todos los registros de asistencia
      final response = await http.get(
        Uri.parse('$url?populate=*'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cargar las asistencias');
      }

      final attendances = json.decode(response.body)['data'];

      // Paso 2: Encontrar el registro de asistencia específico
      final attendance = attendances.firstWhere(
        (attendance) =>
            attendance['attributes']['user']['data']['attributes']["cedula"].toString() == userCedula &&
            attendance['attributes']['course']['data']['id'].toString() == courseId,
        orElse: () => null,
      );

      if (attendance == null) {
        throw Exception('Registro de asistencia no encontrado para userId $userCedula y courseId $courseId');
      }

      final attendanceId = attendance['id'];

      // Paso 3: Obtener los detalles del registro de asistencia específico
      final attendanceResponse = await http.get(
        Uri.parse('$url/$attendanceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (attendanceResponse.statusCode != 200) {
        throw Exception('Error al cargar los detalles de asistencia');
      }

      // Paso 5: Actualizar el registro de asistencia con las ausencias consecutivas reiniciadas
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
        throw Exception('Error al actualizar la asistencia');
      }

    } catch (e) {
      // ignorar
    }
  }

  Future<List<User>> getUsersNotEnrolledInCourse(Course course, String? jwt) async {
    final courseUrl = '$baseUrl/api/courses/${course.id}?populate=*';
    final usersUrl = '$baseUrl/api/users';

    try {
      // Obtener detalles del curso
      final courseResponse = await http.get(
        Uri.parse(courseUrl),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (courseResponse.statusCode != 200) {
        throw Exception('Error al cargar los detalles del curso');
      }

      final courseData = json.decode(courseResponse.body)['data']['attributes'];
      final courseUsersData = courseData['users']['data'] as List;
      final List<String> courseUserIds = courseUsersData.map((user) => user["attributes"]['cedula'] as String).toList();

      // Obtener todos los usuarios
      final usersResponse = await http.get(
        Uri.parse(usersUrl),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (usersResponse.statusCode != 200) {
        throw Exception('Error al cargar los usuarios');
      }

      final allUsersData = json.decode(usersResponse.body) as List;
      List<User> allUsers = allUsersData.map((userJson) => User.fromJson(userJson)).toList();

      // Filtrar usuarios que no están inscritos en el curso
      List<User> usersNotInCourse = allUsers.where((user) => !courseUserIds.contains(user.cedula)).toList();

      return usersNotInCourse;
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> getAllUsers(String? jwt) async {
    final usersUrl = '$baseUrl/api/users';

    try {
      // Obtener todos los usuarios
      final usersResponse = await http.get(
        Uri.parse(usersUrl),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (usersResponse.statusCode != 200) {
        throw Exception('Error al cargar los usuarios');
      }

      final allUsersData = json.decode(usersResponse.body) as List;
      List<User> allUsers = allUsersData.map((userJson) => User.fromJson(userJson)).toList();

      return allUsers;
    } catch (e) {
      return [];
    }
  }
}
