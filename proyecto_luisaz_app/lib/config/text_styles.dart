import 'package:flutter/material.dart';

class TextStyles {

  //Estilo para Titulos
  static TextStyle titles({double? fontSize, Color? color, FontWeight? fontWeight}) {
    return const TextStyle(
      fontSize: 40.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Times New Roman'
    );
  }

  //Estilo para el texto de ejemplo de FieldBoxes
  static TextStyle placeholderForTextFields({double? fontSize, Color? color, FontWeight? fontWeight}) {
    return const TextStyle(
      color: Colors.grey,
      fontSize: 15,
      fontFamily: "Times New Roman"
    );
  }

  //Estilo para mensajes de error
  static TextStyle errorMessages({double? fontSize, Color? color, FontWeight? fontWeight}) {
    return const TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    );
  }

  //Estilo para texto de botones
  static TextStyle buttonTexts({double? fontSize, Color? color, FontWeight? fontWeight}) {
    return const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontFamily: "Times New Roman"
    );
  }
  
  
}