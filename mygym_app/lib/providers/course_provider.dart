import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mygym_app/models/course.dart';
import 'package:mygym_app/models/user.dart';
import 'package:mygym_app/providers/local_storage_provider.dart';

// Proveedor de cursos que extiende ChangeNotifier para notificar cambios en los datos a los listeners.
class CourseProvider extends ChangeNotifier {
  // Instancia de LocalStorageProvider que será configurada más tarde.
  late LocalStorageProvider localStorageProvider;
  // JWT del usuario actual.
  String? currentUserJWT = "";
  // Mensaje de error.
  String errorMessage = "";

  // URL base de la API, obtenida de variables de entorno.
  String baseUrl = dotenv.env['BASE_URL']!;
  // Lista de cursos en los que el usuario actual está inscrito.
  List<Course> currentUserEnrolledCourses = [];

  // Método para configurar el LocalStorageProvider.
  Future<void> setLocalStorageProvider(LocalStorageProvider x) async {
    localStorageProvider = x;
    currentUserJWT = await localStorageProvider.getCurrentUserJWT(); // Obtener JWT del usuario actual.
  }

  // Método para cargar la lista de cursos en los que el usuario actual está inscrito.
  Future<void> loadcurrentUserEnrolledCoursesList() async {
    currentUserEnrolledCourses.clear(); // Limpiar lista actual de cursos.

    if (currentUserEnrolledCourses.isEmpty) {
      final url = Uri.parse("$baseUrl/api/courses?populate=users");

      // Solicitar lista de cursos desde la API.
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentUserJWT',
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Parsear cursos.
        final coursesData = jsonResponse['data'] as List<dynamic>;
        for (var courseData in coursesData) {
          final course = Course.fromJson(courseData);
          currentUserEnrolledCourses.add(course);
        }

        // Filtrar cursos si el usuario no es administrador.
        if (await localStorageProvider.getCurrentUserRole() != "Administrator") {
          filterCoursesByEnrolledUser(await localStorageProvider.getCurrentUserUsername());
        }

        notifyListeners(); // Notificar cambios a los listeners.
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    }
  }

  // Método para filtrar los cursos en los que el usuario actual está inscrito.
  Future<void> filterCoursesByEnrolledUser(String? username) async {

    if (currentUserEnrolledCourses.isEmpty) {
      return;
    }

    if (username == null) {
      return;
    }

    List<Course> filteredCourses = currentUserEnrolledCourses.where((course) {
      bool userFound = course.usersEnrolled.any((user) => (user).username == username);
      return userFound;
    }).toList();

    currentUserEnrolledCourses = filteredCourses;
    notifyListeners();
  }

  // Método para limpiar el mensaje de error.
  Future<void> clearErrorMessage() async {
    errorMessage = "";
  }

  // Método para crear un curso nuevo.
  Future<bool> createCourse(String name, String capacity, String date, String time) async {
    final url = Uri.parse('$baseUrl/api/courses');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $currentUserJWT',
    };

    DateTime parsedDateTime = DateTime.parse('$date $time');
    String formattedDateTime = parsedDateTime.toUtc().toIso8601String(); 
    
    final body = jsonEncode({
      'data': {
        'name': name,
        'capacity': int.parse(capacity),
        'schedule': formattedDateTime,
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        await loadcurrentUserEnrolledCoursesList(); // Recargar lista de cursos.
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Método para actualizar un curso existente.
  Future<bool> updateCourse(String name, String capacity, String date, String time, int id) async {
    final url = Uri.parse('$baseUrl/api/courses/$id');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $currentUserJWT',
    };

    DateTime parsedDateTime = DateTime.parse('$date $time');
    String formattedDateTime = parsedDateTime.toUtc().toIso8601String(); 
    
    final body = jsonEncode({
      'data': {
        'name': name,
        'capacity': int.parse(capacity),
        'schedule': formattedDateTime,
      }
    });

    try {
      final response = await http.put(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        await loadcurrentUserEnrolledCoursesList(); // Recargar lista de cursos.
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Método para eliminar un curso.
  Future<bool> deleteCourse(Course course) async {
    if (course.usersEnrolled.isNotEmpty) {
      errorMessage = "(!) Este curso no se puede eliminar\nporque tiene usuarios enlistados";
      notifyListeners();
      return false;
    }
    final url = Uri.parse('$baseUrl/api/courses/${course.id}');

    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentUserJWT',
      });

      if (response.statusCode == 200) {
        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  // Método para obtener un curso por su ID.
  Future<Course?> getCourseById(String id) async {
    try {
      // Iterar sobre la lista para encontrar el curso con el ID coincidente.
      for (Course course in currentUserEnrolledCourses) {
        if (course.id == id) {
          return course;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Método para desinscribir un usuario de un curso.
  Future<void> unenrollUserFromCourse(User user, Course course, String? jwtToken) async {
    final url = '$baseUrl/api/courses';

    try {
      // Paso 1: Obtener todos los registros de cursos.
      final response = await http.get(
        Uri.parse('$url?populate=*'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load courses');
      }

      final courses = json.decode(response.body)['data'];

      // Paso 2: Encontrar el registro del curso específico.
      final courseRecord = courses.firstWhere(
        (courseData) => courseData['id'].toString() == course.id,
        orElse: () => null,
      );

      if (courseRecord == null) {
        throw Exception('Course record not found for courseId ${course.id}');
      }

      final courseUsers = courseRecord['attributes']['users']['data'];

      // Paso 3: Remover el usuario de la lista de usuarios del curso.
      final updatedUsers = courseUsers.where((userData) => userData['attributes']['cedula'] != user.cedula).toList();

      // Paso 4: Actualizar el registro del curso con la lista de usuarios modificada.
      final updateResponse = await http.put(
        Uri.parse('$url/${course.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({
          'data': {
            'users': updatedUsers.map((user) => {'id': user['id']}).toList(),
          },
        }),
      );

      if (updateResponse.statusCode != 200) {
        throw Exception('Failed to update course');
      }

    // ignore: empty_catches
    } catch (e) {
    }
  }
}
