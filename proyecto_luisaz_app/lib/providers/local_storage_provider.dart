import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:proyecto_luisaz_app/providers/auth_provider.dart';
import 'package:proyecto_luisaz_app/services/local_database.dart';

class LocalStorageProvider extends ChangeNotifier {
  late AuthProvider authProvider;
  final LocalDatabase localDatabase = LocalDatabase();

  void setAuthProvider(AuthProvider x) {
    localDatabase.setAuthProvider(x);
  }

  Future<void> saveCurrentUserData(Map<String, dynamic> data, String? jwt) async {
    await localDatabase.saveCurrentUserData(data, jwt);
  }

  Future<String?> getCurrentUserJWT() async{
    return await localDatabase.getCurrentUserJWT();
  }

  Future<void> logoutCurrentUser() async {
    await localDatabase.logout();
  }

  Future<String?> getCurrentUserUsername() async {
    return await localDatabase.getCurrentUserUsername();
  }

  Future<String?> getCurrentUserRole() async {
    return await localDatabase.getCurrentUserRole();
  }

}
