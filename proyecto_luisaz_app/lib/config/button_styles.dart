import 'package:flutter/material.dart';

class ButtonStyles {

  static ButtonStyle primaryButton({
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    TextStyle? textStyle,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? const Color.fromARGB(255, 1, 61, 110),
      foregroundColor: foregroundColor ?? Colors.white,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      textStyle: textStyle,
    );
  }
}
