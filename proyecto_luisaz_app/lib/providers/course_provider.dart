import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_luisaz_app/models/course.dart';
import 'package:proyecto_luisaz_app/models/current_user_response.dart';
import 'package:proyecto_luisaz_app/providers/local_storage_provider.dart';

class CourseProvider extends ChangeNotifier {

  late LocalStorageProvider localStorageProvider;
  String? currentUser = "";

  String baseUrl = dotenv.env['BASE_URL']!;
  List<Course> currentUserEnrolledCourses = [];

  Future<void> setLocalStorageProvider(LocalStorageProvider x) async {
    localStorageProvider = x;
  }

  Future<void> loadcurrentUserEnrolledCoursesList() async {

    currentUserEnrolledCourses.clear();

    if (currentUserEnrolledCourses.isEmpty) {
      final url = Uri.parse("$baseUrl/api/courses?populate=users");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        //Guardar cursos
        final coursesData = jsonResponse['data'] as List<dynamic>;
        for (var courseData in coursesData) {
          final attributes = courseData['attributes'];
          final usersData = attributes['users']['data'] as List<dynamic>;

          // Parse users enrolled
          List<User> usersEnrolled = [];
          for (var userData in usersData) {
            final userAttributes = userData['attributes'] as Map<String, dynamic>;
            // Append the id to the attributes
            userAttributes['id'] = userData['id'];
            userAttributes['role'] = await localStorageProvider.getCurrentUserRole();
            usersEnrolled.add(User.fromJson(userAttributes));
          }

          final course = Course(
            courseId: attributes['courseId'],
            name: attributes['name'],
            capacity: attributes['capacity'],
            schedule: DateTime.parse(attributes['schedule']),
            usersEnrolled: usersEnrolled,
          );

          
          currentUserEnrolledCourses.add(course);
        }

        if(await localStorageProvider.getCurrentUserRole() != "Administrator"){
          filterCoursesByEnrolledUser(await localStorageProvider.getCurrentUserUsername());
        }
        

        notifyListeners();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    }
  }

  Future<void> filterCoursesByEnrolledUser(String? username) async {
    
    if(currentUserEnrolledCourses.isEmpty){
      return;
    }

    if(username == null){
      return;
    }

    List<Course> filteredCourses = currentUserEnrolledCourses.where((course) {
      return course.usersEnrolled.any((user) => user.username == username);
    }).toList();

    currentUserEnrolledCourses = filteredCourses;
  }
}
