import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mygym_app/models/course.dart';
import 'package:mygym_app/models/user.dart';
import 'package:mygym_app/providers/local_storage_provider.dart';

class CourseProvider extends ChangeNotifier {
  late LocalStorageProvider localStorageProvider;
  String? currentUserJWT = "";
  String errorMessage = "";

  String baseUrl = dotenv.env['BASE_URL']!;
  List<Course> currentUserEnrolledCourses = [];

  Future<void> setLocalStorageProvider(LocalStorageProvider x) async {
    localStorageProvider = x;
    currentUserJWT = await localStorageProvider.getCurrentUserJWT();
  }

  Future<void> loadcurrentUserEnrolledCoursesList() async {
    currentUserEnrolledCourses.clear();

    if (currentUserEnrolledCourses.isEmpty) {
      final url = Uri.parse("$baseUrl/api/courses?populate=users");

      //print("CURRENT USER JWT: $currentUserJWT");

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentUserJWT',
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Parse courses
        final coursesData = jsonResponse['data'] as List<dynamic>;
        for (var courseData in coursesData) {
          final course = Course.fromJson(courseData);
          currentUserEnrolledCourses.add(course);
        }

        if (await localStorageProvider.getCurrentUserRole() != "Administrator") {
          filterCoursesByEnrolledUser(await localStorageProvider.getCurrentUserUsername());
        }

        notifyListeners();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    }
  }


  Future<void> filterCoursesByEnrolledUser(String? username) async {
    print("Filtering courses for user: $username");

    if (currentUserEnrolledCourses.isEmpty) {
      print("No courses available to filter.");
      return;
    }

    if (username == null) {
      print("Username is null. Cannot filter courses.");
      return;
    }

    print("Current courses: ${currentUserEnrolledCourses.length}");
    List<Course> filteredCourses = currentUserEnrolledCourses.where((course) {
      bool userFound = course.usersEnrolled.any((user) => (user).username == username);
      print("Checking course: ${course.name}, user found: $userFound");
      return userFound;
    }).toList();

    print("Filtered courses: ${filteredCourses.length}");
    currentUserEnrolledCourses = filteredCourses;
    notifyListeners();
  }

  Future<void> clearErrorMessage () async {
    errorMessage = "";
  }

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

        await loadcurrentUserEnrolledCoursesList();
        return true;

      } else {
        // Handle other status codes or errors
        print('Failed to create course: ${response.statusCode}');
        print(response.body);
        return false;
      }
    } catch (e) {
      // Handle network or other errors
      print('Error creating course: $e');
      return false;
    }
  }

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

        await loadcurrentUserEnrolledCoursesList();
        return true;

      } else {
        // Handle other status codes or errors
        print('Failed to create course: ${response.statusCode}');
        print(response.body);
        return false;
      }
    } catch (e) {
      // Handle network or other errors
      print('Error creating course: $e');
      return false;
    }
  }

  Future<bool> deleteCourse(Course course) async {

    if(course.usersEnrolled.isNotEmpty){
      errorMessage = "(!) Este curso no se puede eliminar\nporque tiene usuarios enlistados";
      notifyListeners(); 
      return false;
    }
    final url = Uri.parse('$baseUrl/api/courses/${course.id}');
    print("URL: $url");

    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentUserJWT',
      });

      if (response.statusCode == 200) {
        print('Course deleted successfully.');
        notifyListeners(); 
        return true;
      } else {
        print('Failed to delete course. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        notifyListeners(); 
        return false;
      }
    } catch (error) {
      print('Error deleting course: $error');
      return false;
    }
  }

  Future<Course?> getCourseById(String id) async {
    try {
      // Iterate through the list to find the course with the matching id
      for (Course course in currentUserEnrolledCourses) {
        if (course.id == id) {
          return course;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching course by id: $e');
      return null;
    }
  }

  Future<void> unenrolledUserFromCourse(User user, Course course, String? jwtToken) async {
    final url = '$baseUrl/api/courses';

    try {
      // Step 1: Fetch all course records
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

      // Step 2: Find the specific course record
      final courseRecord = courses.firstWhere(
        (courseData) => courseData['id'].toString() == course.id,
        orElse: () => null,
      );

      if (courseRecord == null) {
        throw Exception('Course record not found for courseId ${course.id}');
      }

      final courseUsers = courseRecord['attributes']['users']['data'];

      // Step 3: Remove the user from the course's user list
      final updatedUsers = courseUsers.where((userData) => userData['attributes']['cedula'] != user.cedula).toList();

      // Step 4: Update the course record with the modified user list
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

      print('User unenrolled successfully');
    } catch (e) {
      print('Error: $e');
    }
  }
}
