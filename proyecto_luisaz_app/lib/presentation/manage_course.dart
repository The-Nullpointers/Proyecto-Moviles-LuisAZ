import 'package:flutter/material.dart';
import 'package:proyecto_luisaz_app/config/button_styles.dart';
import 'package:proyecto_luisaz_app/config/text_styles.dart';
import 'package:proyecto_luisaz_app/models/course.dart';

class ManageCoursePage extends StatefulWidget {
  const ManageCoursePage({super.key});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePageState();
}

class _ManageCoursePageState extends State<ManageCoursePage> {
  late Course currentCourse;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the currentCourse from arguments
    currentCourse = ModalRoute.of(context)!.settings.arguments as Course;

    _dateController = TextEditingController(
        text: "${currentCourse.schedule.year}-${currentCourse.schedule.month.toString().padLeft(2, '0')}-${currentCourse.schedule.day.toString().padLeft(2, '0')}");
    _timeController = TextEditingController(
        text: "${currentCourse.schedule.hour.toString().padLeft(2, '0')}:${currentCourse.schedule.minute.toString().padLeft(2, '0')}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 160, 225, 255),

        title: Text(
          "*Null's Gym",
          style: TextStyles.subtitles(fontSize: 30, fontWeight: FontWeight.w800),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            "Modificar Curso",
            style: TextStyles.titles(),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),

            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  initialValue: currentCourse.name,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Curso',
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      currentCourse.name = value;
                    });
                  },
                ),

                const SizedBox(height: 20),
                TextFormField(
                  initialValue: currentCourse.capacity.toString(),
                  decoration: InputDecoration(
                    labelText: 'Capacidad',
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      currentCourse.capacity = int.parse(value);
                    });
                  },
                ),

                const SizedBox(height: 20),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),

                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: currentCourse.schedule,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        currentCourse.schedule = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          currentCourse.schedule.hour,
                          currentCourse.schedule.minute,
                        );
                        _dateController.text =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),
                TextFormField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Hora',
                    labelStyle: TextStyles.placeholderForTextFields(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(currentCourse.schedule),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        currentCourse.schedule = DateTime(
                          currentCourse.schedule.year,
                          currentCourse.schedule.month,
                          currentCourse.schedule.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        _timeController.text =
                            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      child: ElevatedButton(
                        style: ButtonStyles.primaryButton(
                          backgroundColor: const Color.fromARGB(255, 0, 96, 131),
                        ),
                        onPressed: () {
                          saveOrUpdateCourse(currentCourse);
                        },
                        child: Text(
                          'Guardar Curso',
                          style: TextStyles.buttonTexts(),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      child: ElevatedButton(
                        style: ButtonStyles.primaryButton(
                          backgroundColor: const Color.fromARGB(255, 237, 59, 19),
                        ),
                        onPressed: () {
                          deleteCourse(currentCourse.courseId);
                        },
                        child: Text(
                          'Borrar Curso',
                          style: TextStyles.buttonTexts(),
                        ),
                      ),
                    ),

                  ],
                  
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: ElevatedButton(
                    style: ButtonStyles.primaryButton(
                      backgroundColor: const Color.fromARGB(255, 0, 96, 131),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Volver',
                      style: TextStyles.buttonTexts(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void saveOrUpdateCourse(Course course) {
    // Use courseProvider to save or update the course
    print('Saving/Updating course: ${course.name}');
    // courseProvider.saveOrUpdateCourse(course);
  }

  void deleteCourse(String courseId) {
    // Use courseProvider to delete the course
    print('Deleting course with ID: $courseId');
    // courseProvider.deleteCourse(courseId);
  }
}
