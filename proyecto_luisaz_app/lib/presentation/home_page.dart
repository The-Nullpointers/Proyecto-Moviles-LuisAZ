import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Proyecto Moviles Luis AZ"),
        actions: [

          IconButton(
            onPressed: (){}, 
            icon: const Icon(Icons.settings)
          ),
          
        ],
      ),

      body: const Center(
        child: Column(
          children: [
            Text("PLACEHOLDER")
          ],
        ),
      ),
    );
  }
}