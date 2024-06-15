import 'package:mygym_app/models/user.dart';

class Course {
  final String id;
  String name;
  int capacity;
  DateTime schedule;
  final List<User> usersEnrolled;

  Course({
    required this.id,
    required this.name,
    required this.capacity,
    required this.schedule,
    required this.usersEnrolled,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(), // Convert id to string here
      name: json['attributes']['name'],
      capacity: json['attributes']['capacity'],
      schedule: DateTime.parse(json['attributes']['schedule']),
      usersEnrolled: (json['attributes']['users']['data'] as List<dynamic>)
          .map((userData) => User.fromJson(userData['attributes']))
          .toList(),
    );
  }
}
