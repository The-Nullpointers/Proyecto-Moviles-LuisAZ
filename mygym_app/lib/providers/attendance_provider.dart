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
      print("UPDATE STATUS: USER ${user.username}, STATUS: ${attendanceStatus}");
      attendanceList[existingIndex][user] = attendanceStatus;
    } else {
      print("NEW ENTRY: USER ${user.username}, STATUS: ${attendanceStatus}");
      attendanceList.add({user: attendanceStatus});
    }
    
  }

  Future<bool> registerConsecutiveAbsences(User user) async {
    return false;
  }

  Future<String?> getUserAttendanceList(User user) async {

    print("USERS: ${attendanceList.length}");
    
    for (Map<User, String?> attendanceEntry in attendanceList) {
      User key = attendanceEntry.keys.first;
      if (key == user) {
        print("RETURNING ATTENDANCE: USER ${user.username}, STATUS: ${attendanceEntry[key]}");
        return attendanceEntry[key];
      }
    }
    
    print("CANT RETURN ATTENDANCE: USER ${user.username}");
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
      // Step 1: Fetch all attendance records
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

      // Step 2: Find the specific attendance record
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

      // Step 3: Fetch the details of the specific attendance record
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

      // Step 4: Increment the consecutive_absences field
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

      // Step 5: Update the attendance record with the incremented consecutive_absences
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



      print('Attendance updated successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> clearConsecutiveAbsences(User user, Course course, String? jwtToken) async {
    String userCedula = user.cedula;
    String courseId = course.id;

    final url = '$baseUrl/api/attendaces';

    try {
      // Step 1: Fetch all attendance records
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

      // Step 2: Find the specific attendance record
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

      // Step 3: Fetch the details of the specific attendance record
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

      // Step 5: Update the attendance record with the incremented consecutive_absences
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

      print('Attendance updated successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<User>> getUsersNotEnrolledInCourse(Course course, String? jwt) async {
    final courseUrl = '$baseUrl/api/courses/${course.id}?populate=*';
    final usersUrl = '$baseUrl/api/users';

    try {
      // Fetch course details
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

      // Fetch all users
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

      // Filter out users already enrolled in the course
      List<User> usersNotInCourse = allUsers.where((user) => !courseUserIds.contains(user.cedula)).toList();

      for(var user in usersNotInCourse){
        print("USER ${user.username}: ${user.id}");
      }

      return usersNotInCourse;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<User>> getAllUsers(String? jwt) async {
    final usersUrl = '$baseUrl/api/users';

    try {
      
      // Fetch all users
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
      print('Error: $e');
      return [];
    }
  }

  Future<List<User>> getUsersEnrolledInCourse(Course course, String? jwt) async {
    final courseUrl = '$baseUrl/api/courses/${course.id}?populate=*';
    final usersUrl = '$baseUrl/api/users';

    try {
      // Fetch course details
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

      // Fetch all users
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

      // Filter out users already enrolled in the course
      List<User> usersNotInCourse = allUsers.where((user) => courseUserIds.contains(user.cedula)).toList();

      for(var user in usersNotInCourse){
        print("USER ${user.username}: ${user.id}");
      }

      return usersNotInCourse;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  


  


  Future<bool> enrollClient(String selectedItem, Course course, String? jwt) async {
    print("SELECTED ITEM: $selectedItem");
    print("SELECTED ITEM LENGTH: ${selectedItem.length}");
    // Step 1: Split selectedItem to extract cedula
    List<String> parts = selectedItem.split(' - ');
    
    if (parts.length < 2) {
      print('Invalid selectedItem format: $selectedItem');
      return false;
    }

    String cedula = parts[1];

    // Step 2: Fetch user ID using cedula
    String userId = await fetchUserIdByCedula(cedula, jwt!);
    if (userId == null) {
      print('Failed to fetch user ID for cedula: $cedula');
      return false;
    }

    // Step 3: Enroll user in course
    final url = Uri.parse('$baseUrl/api/courses/${course.id}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt',
    };
    print("USER ID TO ENROLL: ${userId}");
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
        print('User enrolled successfully');
        // Step 4: Create attendance record
        await createAttendance(userId, course.id, jwt);
        return true;
      } else {
        print('Failed to enroll user: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error enrolling user: $e');
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

    print("URL: $url");

    print("CREATE ATTENDANCE: COURSE ID: $courseId USER ID: $userId");
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
        print('Attendance record created successfully');
      } else {
        print('Failed to create attendance record: ${response.body}');
      }
    } catch (e) {
      print('Error creating attendance record: $e');
    }
  }
  
  Future<bool> unenrollClient(String selectedItem, Course course, String? jwt) async {
    try {
      List<String> parts = selectedItem.split(' - ');
    
      if (parts.length < 2) {
        print('Invalid selectedItem format: $selectedItem');
      return false;
      }

    String userCedula = parts[1];
      String userId = await fetchUserIdByCedula(userCedula, jwt!);

      // Step 2: Remove the user from the course's users collection
      bool userDisconnected = await disconnectUserFromCourse(userId, course.id, jwt);
      if (!userDisconnected) {
        print('Failed to disconnect user from course.');
        return false;
      }

      // Step 3: Delete the attendance row
      bool attendanceDeleted = await deleteAttendance(userId, course.id, jwt);
      if (!attendanceDeleted) {
        print('Failed to delete attendance.');
        // Optionally handle this failure, depending on your application logic
      }

      // Return true if both operations were successful
      return userDisconnected && attendanceDeleted;
    } catch (e) {
      print('Exception while unenrolling client: $e');
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

        print("CEDULA: $cedula");

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
      print('Exception while fetching user ID: $e');
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
      print('Exception while disconnecting user from course: $e');
      return false;
    }
  }

  Future<bool> deleteAttendance(String userId, String courseId, String jwt) async {
    int userIdInt = int.parse(userId);
    int courseIdInt = int.parse(courseId);

    print("DELETING ATTENDANCE: COURSE ID: $courseIdInt, USER ID: $userIdInt");

    try {
      // Fetch the attendance records
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
      print("ATTENDANCE ID: $attendanceId");

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
      print('Exception while deleting attendance: $e');
      return false;
    }
  }



}