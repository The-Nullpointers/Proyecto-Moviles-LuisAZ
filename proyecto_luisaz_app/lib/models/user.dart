import 'package:isar/isar.dart';

class User {
  int cedula;
  String username;
  String email;
  String? provider; // Make it optional
  bool? confirmed; // Make it optional
  bool? blocked; // Make it optional
  DateTime? createdAt; // Make it optional
  DateTime? updatedAt; // Make it optional
  String? role; // Make it optional

  User({
    required this.cedula,
    required this.username,
    required this.email,
    this.provider, // Optional parameter
    this.confirmed, // Optional parameter
    this.blocked, // Optional parameter
    this.createdAt, // Optional parameter
    this.updatedAt, // Optional parameter
    this.role, // Optional parameter
  });
}
