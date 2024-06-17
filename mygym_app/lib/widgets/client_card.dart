import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/current_user.dart';
import 'package:mygym_app/models/user.dart';
import 'package:mygym_app/providers/attendance_provider.dart';
import 'package:provider/provider.dart';

class ClientCard extends StatefulWidget {
  final User user;

  const ClientCard({super.key, required this.user});

  @override
  State<ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<ClientCard> {

  final List<Color> colors = [
    Colors.teal.shade100,
    Colors.amber.shade100,
    Colors.cyan.shade100,
    Colors.lime.shade100,
  ];

  late final Color cardColor;

  @override
  void initState() {
    super.initState();
    cardColor = getRandomColor();
  }

  Color getRandomColor() {
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {

    //Providers ---------------------------------------------
    final attendanceProvider = context.read<AttendanceProvider>();
    //Providers ---------------------------------------------

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.username,
              style: TextStyles.subtitles(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Cédula: ${widget.user.cedula}",
              style: TextStyles.body(),
            ),
            Text(
              "Correo: ${widget.user.email}",
              style: TextStyles.body(),
            ),

            const SizedBox(height: 20,),
            

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ButtonStyles.primaryButton(backgroundColor: Color.fromARGB(255, 159, 25, 25)),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/manageClient',
                      arguments: widget.user,
                    );
                  },
                  child: Text('Administrar Cliente', style: TextStyles.buttonTexts(fontSize: 16,color: Colors.white)),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
