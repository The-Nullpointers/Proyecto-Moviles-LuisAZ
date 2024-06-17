import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/current_user.dart';
import 'package:mygym_app/models/user.dart';
import 'package:mygym_app/providers/attendance_provider.dart';
import 'package:provider/provider.dart';

class AttendanceClientCard extends StatefulWidget {
  final User user;

  const AttendanceClientCard({Key? key, required this.user}) : super(key: key);

  @override
  State<AttendanceClientCard> createState() => _AttendanceClientCardState();
}

class _AttendanceClientCardState extends State<AttendanceClientCard> {
  late final Color cardColor;
  bool isPresent = false;

  final List<Color> colors = [
    Colors.teal.shade100,
    Colors.amber.shade100,
    Colors.cyan.shade100,
    Colors.lime.shade100,
  ];

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
    final attendanceProvider = context.read<AttendanceProvider>();

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
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Marcar Asistencia',
                    style: TextStyle(
                      color: isPresent ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: isPresent,
                    onChanged: (value) async {
                      setState(() {
                        isPresent = value;
                        
                      });
                      final status = value ? 'Presente' : 'Ausente';
                      await attendanceProvider.updateUserAttendanceStatus(widget.user, status);
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
