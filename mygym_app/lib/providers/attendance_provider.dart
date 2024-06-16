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

  Future<void> clearAttendanceList() async {
    attendanceList.clear();
  }


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
        await courseProvider.unenrolledUserFromCourse(user, course, jwtToken);
        
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


  
}
