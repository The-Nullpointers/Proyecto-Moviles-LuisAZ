import 'package:flutter/material.dart';

class TextStyles {

  // Estilo para Titulos
  static TextStyle titles({double? fontSize, Color? color, FontWeight? fontWeight, String? fontFamily}) {
    return TextStyle(
      fontSize: fontSize ?? 40.0,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color,
      fontFamily: fontFamily ?? 'Times New Roman',
    );
  }

  // Estilo para Subtitulos
  static TextStyle subtitles({double? fontSize, Color? color, FontWeight? fontWeight, String? fontFamily}) {
    return TextStyle(
      fontSize: fontSize ?? 20.0,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color,
      fontFamily: fontFamily ?? 'Times New Roman',
    );
  }

  // Estilo para el cuerpo texto
  static TextStyle body({double? fontSize, Color? color, FontWeight? fontWeight, String? fontFamily}) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      fontFamily: fontFamily ?? 'Times New Roman',
    );
  }

  // Estilo para el texto de ejemplo de FieldBoxes
  static TextStyle placeholderForTextFields({double? fontSize, Color? color, FontWeight? fontWeight, String? fontFamily}) {
    return TextStyle(
      fontSize: fontSize ?? 15,
      color: color ?? Colors.grey,
      fontWeight: fontWeight,
      fontFamily: fontFamily ?? 'Times New Roman',
    );
  }

  // Estilo para mensajes de error
  static TextStyle errorMessages({double? fontSize, Color? color, FontWeight? fontWeight, String? fontFamily}) {
    return TextStyle(
      fontSize: fontSize,
      color: color ?? Colors.red,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontFamily: fontFamily ?? 'Times New Roman',
    );
  }

  // Estilo para texto de botones
  static TextStyle buttonTexts({double? fontSize, Color? color, FontWeight? fontWeight, String? fontFamily}) {
    return TextStyle(
      fontSize: fontSize ?? 20,
      fontWeight: fontWeight,
      color: color ?? Colors.white,
      fontFamily: fontFamily ?? 'Times New Roman',
    );
  }
}
