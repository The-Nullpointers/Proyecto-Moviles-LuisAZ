import 'package:flutter/material.dart';
import 'package:mygym_app/models/course.dart';

class UnenrollClientPage extends StatefulWidget {
  const UnenrollClientPage({super.key});

  @override
  State<UnenrollClientPage> createState() => _UnenrollClientPageState();
}

class _UnenrollClientPageState extends State<UnenrollClientPage> {

  late Course currentCourse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Course) {
      currentCourse = args;
    } else {
      currentCourse = Course(
        id: "",
        name: '',
        capacity: 0,
        schedule: DateTime.now(),
        usersEnrolled: [],
      );
    }


  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}