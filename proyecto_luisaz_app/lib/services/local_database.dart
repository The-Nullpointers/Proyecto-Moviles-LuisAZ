import 'package:flutter/scheduler.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proyecto_luisaz_app/models/current_user.dart';
import 'package:proyecto_luisaz_app/providers/auth_provider.dart';

class LocalDatabase {
  late Future<Isar> db;
  late AuthProvider authProvider;

  void setAuthProvider(AuthProvider x){
    authProvider = x;
  }

  LocalDatabase() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open([CurrentUserSchema],
          inspector: true, directory: dir.path);
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> saveCurrentUserData(Map<String, dynamic> userData, String? jwt) async {
    final isar = await db;

    final currentUser = CurrentUser()
      ..id = userData['id']
      ..cedula = int.parse(userData['cedula'])
      ..username = userData['username']
      ..email = userData['email']
      ..role = userData['role']['name']
      ..jwt = jwt ?? '';

    try {
      await isar.writeTxn(() async {
        await isar.currentUsers.clear();
        await isar.currentUsers.put(currentUser);
      });

    } catch (e) {
      
    }
  }

  Future<String?> getCurrentUserJWT() async {
    final isar = await db;
    try {

      //Debe haber solo 1 usuario  actual
      final currentUser = await isar.currentUsers.where().findFirst();
      if (currentUser != null) {
        return currentUser.jwt;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    final isar = await db;
    try {
      await isar.writeTxn(() async {
        await isar.currentUsers.clear();
      });
      print('User logged out and data cleared.');
    } catch (e) {
      print('Error during logout: $e');
    }
  } 

  Future<String?> getCurrentUserUsername() async {
    final isar = await db;
    try {

      //Debe haber solo 1 usuario  actual
      final currentUser = await isar.currentUsers.where().findFirst();
      if (currentUser != null) {
        return currentUser.username;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCurrentUserRole() async {
    final isar = await db;
    try {

      //Debe haber solo 1 usuario  actual
      final currentUser = await isar.currentUsers.where().findFirst();
      if (currentUser != null) {
        return currentUser.role;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
