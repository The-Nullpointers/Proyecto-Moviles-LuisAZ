import 'dart:math';

import 'package:flutter/material.dart';
import 'package:proyecto_luisaz_app/config/button_styles.dart';
import 'package:proyecto_luisaz_app/config/text_styles.dart';
import 'package:proyecto_luisaz_app/models/course.dart';

class AdminCourseCard extends StatelessWidget {
  final Course course;
  final List<Color> colors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
  ];

  AdminCourseCard({super.key, required this.course});

  Color getRandomColor() {
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    
    final cardColor = getRandomColor();

    return Card(
      color: cardColor,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name,
              style: TextStyles.subtitles(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Fecha: ${course.schedule.toLocal().toString().split(' ')[0]}",
              style: TextStyles.body(),
            ),
            Text(
              "Hora: ${course.schedule.toLocal().toString().split(' ')[1].substring(0, 5)}",
              style: TextStyles.body(),
            ),
            SizedBox(height: 5),
            Text(
              "Cupos totales: ${course.capacity}",
              style: TextStyles.body(),
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ButtonStyles.primaryButton(),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/manageCourse',
                    arguments: course,
                  );
                },
                child: Text('Administrar Curso', style: TextStyles.buttonTexts(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
