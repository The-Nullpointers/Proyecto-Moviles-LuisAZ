import 'package:isar/isar.dart';
import 'package:proyecto_luisaz_app/models/current_user_response.dart';

class Course {
  String courseId;
  String name;
  int capacity;
  DateTime schedule;
  List<User> usersEnrolled;

  Course({
    required this.courseId,
    required this.name,
    required this.capacity,
    required this.schedule,
    required this.usersEnrolled,
  });
}