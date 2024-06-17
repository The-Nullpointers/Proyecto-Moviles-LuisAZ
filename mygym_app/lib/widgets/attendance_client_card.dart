import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/user.dart';
import 'package:mygym_app/providers/attendance_provider.dart';
import 'package:provider/provider.dart';

class AttendanceClientCard extends StatefulWidget {
  final User user;

  const AttendanceClientCard({super.key, required this.user});

  @override
  State<AttendanceClientCard> createState() => _AttendanceClientCardState();
}

class _AttendanceClientCardState extends State<AttendanceClientCard> {
  final List<String> _items = ["Presente", "Ausente"];
  String? _selectedItem = "Ausente";

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

    attendanceProvider.updateUserAttendanceStatus(widget.user, _selectedItem);

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
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      hint: const Text('Marcar Asistencia'),
                      value: _selectedItem,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyles.subtitles(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _selectedItem == "Presente"
                            ? Colors.green.shade300
                            : _selectedItem == "Ausente"
                                ? Colors.red.shade300
                                : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (String? newValue) async {
                        await attendanceProvider.updateUserAttendanceStatus(widget.user, newValue);
                        setState(() {
                          _selectedItem = newValue!;
                          
                        });
                      },
                      items: _items.map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                    ),
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
