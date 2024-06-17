import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/course.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class QrPage extends StatefulWidget {
  final Course? course;

  const QrPage({Key? key, this.course}) : super(key: key);

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  late Course _currentCourse;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _initializeCourse();
  }

  void _initializeCourse() {
    if (widget.course != null) {
      _currentCourse = widget.course!;
      _isLoading = false;
    } else {
      // If no course is provided, create a new one
      _currentCourse = Course(
        id: '', // Replace with appropriate initialization
        name: 'Nuevo Curso', // Replace with appropriate initialization
        capacity: 10, // Replace with appropriate initialization
        schedule: DateTime.now(), // Replace with appropriate initialization
        usersEnrolled: [], // Replace with appropriate initialization
      );
      _isLoading = false;
    }
  }

  String generateUuid() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  @override
  Widget build(BuildContext context) {
    final uuid = generateUuid(); // Generate UUID when the widget is built

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 160, 225, 255),
        title: Text(
          "*Null's Gym",
          style: TextStyles.subtitles(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        actions: const [],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(), // Display a loading indicator until course is initialized
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Asistencia",
                    style: TextStyles.titles(),
                  ),
                  QrImageView(
                    data: uuid,
                    version: QrVersions.auto,
                    size: 350.0,
                    gapless: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      style: ButtonStyles.primaryButton(),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Volver", style: TextStyles.buttonTexts()),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
