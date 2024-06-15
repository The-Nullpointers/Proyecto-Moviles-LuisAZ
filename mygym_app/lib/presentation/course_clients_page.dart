import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/course.dart';
import 'package:mygym_app/models/user.dart';
import 'package:mygym_app/providers/course_provider.dart';
import 'package:mygym_app/widgets/client_card.dart'; // Import your User model

class CourseClientsPage extends StatefulWidget {

  

  const CourseClientsPage({super.key});

  @override
  State<CourseClientsPage> createState() => _CourseClientsPageState();

  
}

class _CourseClientsPageState extends State<CourseClientsPage> {
  late Course course; 
  final _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Course) {
      course = args;
    } else {
      course = Course(
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
    
    List<User> users = course.usersEnrolled;

    // Providers ---------------------------------------------
    final courseProvider = context.read<CourseProvider>();
    // Providers ---------------------------------------------

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Asistencia - ${course.name}",
              style: TextStyles.titles(fontSize: 30),
            ),
          ),

          SizedBox(
            height: 550,
            width: 400,

            child: Consumer<CourseProvider>(
              builder: (context, courseProvider, child) {
                return Expanded(
                  child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ClientCard(user: user);
                      },
                    ),
                  ),
                );
              }
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20,),
            child: ElevatedButton(
              style: ButtonStyles.primaryButton(
                backgroundColor: Color.fromARGB(255, 0, 96, 131),
              ),
              onPressed: () async {
                await courseProvider.loadcurrentUserEnrolledCoursesList();
                Course? newCourse = await courseProvider.getCourseById(course.id);

                if(newCourse != null){
                  course = newCourse;
                }
          
                setState(() {});
              },
              child: Text(
                'Refrescar Participantes',
                style: TextStyles.buttonTexts(),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Padding(
                padding: const EdgeInsets.only(top: 20, left: 70),
                child: SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    style: ButtonStyles.primaryButton(
                      backgroundColor: const Color.fromARGB(255, 41, 177, 14),
                    ),
                    onPressed: ()  {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Guardar',
                      style: TextStyles.buttonTexts(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 50),
                child: ElevatedButton(
                  style: ButtonStyles.primaryButton(
                    backgroundColor: Color.fromARGB(255, 0, 96, 131),
                  ),
                  onPressed: ()  {
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
        ],
      ),
    );
  }
}
