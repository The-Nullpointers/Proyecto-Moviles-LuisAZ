import 'package:flutter/material.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/course.dart';
import 'package:mygym_app/providers/attendance_provider.dart';
import 'package:mygym_app/providers/course_provider.dart';
import 'package:mygym_app/providers/local_storage_provider.dart';
import 'package:mygym_app/widgets/attendance_client_card.dart';
import 'package:provider/provider.dart';

class CourseClientsPage extends StatefulWidget {
 const CourseClientsPage({super.key});

 @override
 State<CourseClientsPage> createState() => _CourseClientsPageState();
}

class _CourseClientsPageState extends State<CourseClientsPage> {
 late Course course; // Variable que almacenará la información del curso
 final _scrollController = ScrollController(); // Controlador para el scroll
 List<AttendanceClientCard> _clientCards = []; // Lista de tarjetas de clientes

 @override
 void didChangeDependencies() {
  super.didChangeDependencies();

  // Obtener los argumentos de la ruta actual
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

  // Crear las cards de clientes a partir de los usuarios inscritos en el curso
  _clientCards = course.usersEnrolled.map((user) => AttendanceClientCard(user: user)).toList();
 }

 Future<void> refreshClients(CourseProvider courseProvider, AttendanceProvider attendanceProvider) async {

  await courseProvider.loadcurrentUserEnrolledCoursesList();
  Course? newCourse = await courseProvider.getCourseById(course.id);

  if (newCourse != null) {
   setState(() {
    course = newCourse;
    _clientCards = course.usersEnrolled.map((user) => AttendanceClientCard(user: user)).toList();
   });
  }
 }

 @override
 Widget build(BuildContext context) {

  // Providers ---------------------------------------------
  final courseProvider = context.read<CourseProvider>();
  final attendanceProvider = context.read<AttendanceProvider>();
  final localStorageProvider = context.read<LocalStorageProvider>();
  // Providers ---------------------------------------------

  courseProvider.loadcurrentUserEnrolledCoursesList();

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

     FutureBuilder(
      future: null, //refreshClients(courseProvider, attendanceProvider),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
       return Consumer<CourseProvider>(
        builder: (context, courseProvider, _) {
         return Expanded(
          child: Scrollbar(
           controller: _scrollController,
           thumbVisibility: true,
           child: ListView.builder(
            controller: _scrollController,
            itemCount: _clientCards.length,
            itemBuilder: (context, index) {
             return _clientCards[index];
            },
           ),
          ),
         );
        },
       );
      }
     ),

     Padding(
      padding: const EdgeInsets.only(top: 20, left: 20),
      child: ElevatedButton(
       style: ButtonStyles.primaryButton(
        backgroundColor: const Color.fromARGB(255, 0, 96, 131),
       ),
       onPressed: () async {
        await courseProvider.loadcurrentUserEnrolledCoursesList();
        Course? newCourse = await courseProvider.getCourseById(course.id);

        if (newCourse != null) {
         setState(() {
          course = newCourse;
          _clientCards = course.usersEnrolled.map((user) => AttendanceClientCard(user: user)).toList();
         });
        }
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
        child: ElevatedButton(
         style: ButtonStyles.primaryButton(
          backgroundColor: const Color.fromARGB(255, 41, 177, 14),
         ),
         onPressed: () async {

          bool flag = false;

          // Verificar la asistencia de cada usuario
          for (var card in _clientCards) {
           String? attendanceStatus = await attendanceProvider.getUserAttendanceList(card.user);

           if(attendanceStatus == null){
            flag = true;
            break;
           }
          }

          if(flag){
           showDialog(
            context: context,
            builder: (BuildContext context) {
             return AlertDialog(
              title: const Text('Advertencia'),
              content: const Text('Asistencias no marcadas se contarán como ausencias'),
              icon: const Icon(Icons.warning),
              actions: <Widget>[

               Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                 TextButton(
                  onPressed: () async {
                   Navigator.of(context).pop();
                   setState(() {});
                  },
                  child: const Text('Cancelar'),
                 ),

                 TextButton(
                  onPressed: () async {
                    
                   for (var card in _clientCards) {
                    String? attendanceStatus = await attendanceProvider.getUserAttendanceList(card.user);

                    if(attendanceStatus == "Ausente" || attendanceStatus == null){
                     await attendanceProvider.setConsecutiveAbsences(card.user, course, await localStorageProvider.getCurrentUserJWT(), courseProvider);
                     await refreshClients(courseProvider, attendanceProvider);
                    }
                    if(attendanceStatus == "Presente"){
                     await attendanceProvider.clearConsecutiveAbsences(card.user, course, await localStorageProvider.getCurrentUserJWT());
                    }
                   }
                    
                   Navigator.of(context).pop();
                   showDialog(
                    context: context,
                    builder: (BuildContext context) {
                     return AlertDialog(
                      title: const Text('Éxito'),
                      content: const Text('La asistencia ha sido registrada'),
                      icon: const Icon(Icons.check),
                      actions: <Widget>[

                       TextButton(
                        onPressed: () async {

                         Navigator.of(context).pop();
                         Navigator.of(context).pop();
                         setState(() {});
                        },
                        child: const Text('Listo'),
                       ),
                        
                      ],
                     );
                    },
                   );
                  },
                  child: const Text('Aceptar'),
                 ),
                ],
               ),
              ],
             );
            },
           );
          } else {

           showDialog(
            context: context,
            builder: (BuildContext context) {
             return AlertDialog(
              title: const Text('Éxito'),
              content: const Text('La asistencia ha sido registrada'),
              icon: const Icon(Icons.check),
              actions: <Widget>[

               TextButton(
                onPressed: () async {
                  
                 for (var card in _clientCards) {
                  String? attendanceStatus = await attendanceProvider.getUserAttendanceList(card.user);

                  if(attendanceStatus == "Ausente" || attendanceStatus == null){
                   await attendanceProvider.setConsecutiveAbsences(card.user, course, await localStorageProvider.getCurrentUserJWT(), courseProvider);
                   await refreshClients(courseProvider, attendanceProvider);
                  }
                  if(attendanceStatus == "Presente"){
                   await attendanceProvider.clearConsecutiveAbsences(card.user, course, await localStorageProvider.getCurrentUserJWT());
                  }
                 }

                 Navigator.of(context).pop();
                 Navigator.of(context).pop();
                 setState(() {});
                },
                child: const Text('Listo'),
               ),
              ],
             );
            },
           );
          }
         },
         child: Text(
          'Guardar',
          style: TextStyles.buttonTexts(fontWeight: FontWeight.bold),
         ),
        ),
       ),
       Padding(
        padding: const EdgeInsets.only(top: 20, right: 50),
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
     const SizedBox(height: 30),
    ],
   ),
  );
 }
}
