import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mygym_app/config/button_styles.dart';
import 'package:mygym_app/config/text_styles.dart';
import 'package:mygym_app/models/course.dart';
import 'package:mygym_app/providers/course_provider.dart';

class ManageCoursePage extends StatefulWidget {
  const ManageCoursePage({super.key});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePageState();
}

class _ManageCoursePageState extends State<ManageCoursePage> {
  late Course currentCourse;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  String errorMessage = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Course) {
      currentCourse = args;
    } else {
      currentCourse = Course(
        id: "",
        name: '',
        capacity: 0,
        schedule: DateTime.now(),
        usersEnrolled: [],
      );
    }

    _dateController = TextEditingController(
      text: "${currentCourse.schedule.year}-${currentCourse.schedule.month.toString().padLeft(2, '0')}-${currentCourse.schedule.day.toString().padLeft(2, '0')}");
    _timeController = TextEditingController(
      text: "${currentCourse.schedule.hour.toString().padLeft(2, '0')}:${currentCourse.schedule.minute.toString().padLeft(2, '0')}");


  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.read<CourseProvider>();

    _nameController.text = currentCourse.name;
    _capacityController.text = currentCourse.capacity.toString();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 160, 225, 255),
        title: Text(
          "*Null's Gym",
          style: TextStyles.subtitles(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        
      ),
      body: Padding(
        
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Text(
                currentCourse.id != "" ? "Modificar Curso" : "Crear Curso",
                style: TextStyles.titles(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                
                controller: _nameController,
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
                
                controller: _capacityController,
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
                    currentCourse.capacity = int.tryParse(value) ?? 0;
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(errorMessage, style: TextStyles.errorMessages()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ButtonStyles.primaryButton(
                      backgroundColor: const Color.fromARGB(255, 0, 96, 131),
                    ),
                    onPressed: () async {

                      //Crear curso
                      if(currentCourse.id == ""){
                        if(validateAllInputs()){

                          bool result = await courseProvider.createCourse(
                              _nameController.text,
                              _capacityController.text,
                              _dateController.text, 
                              _timeController.text
                            );
            
                          if(result){
                            errorMessage = "";
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Éxito'),
                                  content: Text('El curso ${_nameController.text} ha sido creado correctamente'),
                                  icon: const Icon(Icons.check),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () async {
                                        await courseProvider.loadcurrentUserEnrolledCoursesList();
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
                          
                        } else { setState(() {}); }
                      } else { //Modificar Curso
                      
                        if(validateAllInputs()){
                          bool result = await courseProvider.updateCourse(
                              _nameController.text,
                              _capacityController.text,
                              _dateController.text, 
                              _timeController.text,
                              int.parse(currentCourse.id)
                            );
            
                          if(result){
                            errorMessage = "";
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Éxito'),
                                  content: Text('El curso ${_nameController.text} se ha actualizado'),
                                  icon: const Icon(Icons.check),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () async {
                                        await courseProvider.loadcurrentUserEnrolledCoursesList();
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
                        }
                      }

                      
                      
                      
                    },
                    child: Text(
                      currentCourse.id != "" ? "Modificar Curso" : "Crear Curso",
                      style: TextStyles.buttonTexts(),
                    ),
                  ),
                  
          
                  if(currentCourse.id != "")
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ElevatedButton(
                        style: ButtonStyles.primaryButton(
                          backgroundColor: const Color.fromARGB(255, 159, 25, 25),
                        ),
                      
                        onPressed: () async {
                          if (currentCourse.id != "" && await courseProvider.deleteCourse(currentCourse)) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Éxito'),
                                  content: Text('El curso ${currentCourse.name} ha sido eliminado correctamente'),
                                  icon: const Icon(Icons.check),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () async {
                                        await courseProvider.loadcurrentUserEnrolledCoursesList();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        setState(() {});
                                      },
                                      child: const Text('Ok'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else { errorMessage = courseProvider.errorMessage; setState(() {});}
                        },
                        child: Text(
                          'Borrar Curso',
                          style: TextStyles.buttonTexts(),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 20,),

              if(currentCourse.id != "")
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ButtonStyles.primaryButton(backgroundColor: Color.fromARGB(255, 17, 98, 59)),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/enrollClient',
                          arguments: currentCourse,
                        );
                      },
                      child: Text('Matricular Cliente', style: TextStyles.buttonTexts(fontSize: 16, color: Colors.white)),
                    ),

                    ElevatedButton(
                      style: ButtonStyles.primaryButton(backgroundColor: Color.fromARGB(255, 159, 25, 25)),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/unenrollClient',
                          arguments: currentCourse,
                        );
                      },
                      child: Text('Dar Cliente de Baja', style: TextStyles.buttonTexts(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              
          
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyles.primaryButton(
                  backgroundColor: const Color.fromARGB(255, 0, 96, 131),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  courseProvider.clearErrorMessage();
                },
                child: Text(
                  'Volver',
                  style: TextStyles.buttonTexts(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateAllInputs(){

    if(_nameController.text.isEmpty || _dateController.text.isEmpty || _timeController.text.isEmpty){
      
      errorMessage = "(!) Todos los espacios deben estar completos";
      setState(() {});
      return false;
    }

    if(int.parse(_capacityController.text) <= 0){
      errorMessage = "(!) La capacidad debe ser mayor a 0";
      setState(() {});
      return false;
    } 


    return true;
  }


}
