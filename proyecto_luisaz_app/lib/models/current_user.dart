import 'package:isar/isar.dart';
part 'current_user.g.dart';

@Collection()
class CurrentUser {
  Id? id;

  int cedula = 0;
  String username = "";
  String email = "";
  String savedPassword = "";
  String role = "";
  String jwt = "";
  
}