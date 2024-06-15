import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/user.dart';

class ClientCard extends StatelessWidget {
  final User user;
  final List<Color> colors = [
    Colors.teal.shade100,
    Colors.pink.shade100,
    Colors.amber.shade100,
    Colors.cyan.shade100,
    Colors.lime.shade100,
  ];

  ClientCard({super.key, required this.user});

  Color getRandomColor() {
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    
    final cardColor = getRandomColor();

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.username,
              style: TextStyles.subtitles(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),
            Text(
              "Cédula: ${user.cedula}",
              style: TextStyles.body(),
            ),
            Text(
              "Correo: ${user.email}",
              style: TextStyles.body(),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Asistencia", style: TextStyles.buttonTexts(color: const Color.fromARGB(255, 23, 77, 122)),)
                  ),
                ],
              ),
            )
            
          ],
        ),
      ),
    );
  }
}
