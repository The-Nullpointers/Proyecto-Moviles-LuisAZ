import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/course.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class QrPage extends StatefulWidget {
  final Course? course;

  const QrPage({super.key, this.course});

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
    _initializeCourse(); // Inicializa el curso
  }

  void _initializeCourse() {
    if (widget.course != null) {
      _currentCourse = widget.course!;
      _isLoading = false;
    } else {
      // Si no se proporciona un curso, crea uno nuevo
      _currentCourse = Course(
        id: '', // Reemplazar con la inicialización apropiada
        name: 'Nuevo Curso', // Reemplazar con la inicialización apropiada
        capacity: 10, // Reemplazar con la inicialización apropiada
        schedule: DateTime.now(), // Reemplazar con la inicialización apropiada
        usersEnrolled: [], // Reemplazar con la inicialización apropiada
      );
      _isLoading = false;
    }
  }

  String generateUuid() {
    var uuid = const Uuid();
    return uuid.v4(); // Genera un UUID
  }

  @override
  Widget build(BuildContext context) {
    final uuid = generateUuid(); // Genera un UUID cuando se construye el widget

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
          ? const Center(
              child: CircularProgressIndicator(), // Muestra un indicador de carga hasta que se inicialice el curso
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
                        Navigator.pop(context); // Vuelve a la pantalla anterior
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
