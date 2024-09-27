// ignore: file_names
import 'package:flutter/material.dart';

// Colores personalizados
const _colorCustoms = Color.fromRGBO(254, 166, 33, 1);


const List<Color> _colorThemes = [
  _colorCustoms,
  Colors.orange,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.red,
  Colors.pink,
  Colors.purple,
];

// Tipografías personalizadas
final  List<TextTheme>  _typographyThemes = [
  
  const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      fontFamily: 'Afacad', 
      color: Color.fromARGB(255, 0, 0, 0),)     
  ),
  const TextTheme(
  ),
  const TextTheme(
    
  ),
];

// Clase de Tema Personalizado
class AppTheme {
  final int colorCustom;
  final int typographyCustom;

  AppTheme({
    this.colorCustom = 0,
    this.typographyCustom = 0,
  }) : assert(
          colorCustom >= 0 && colorCustom <= _colorThemes.length - 1,
          'colorCustom must be between 0 and ${_colorThemes.length - 1}',
        ),
        assert(
          typographyCustom >= 0 && typographyCustom <= _typographyThemes.length - 1,
          'typographyCustom must be between 0 and ${_typographyThemes.length - 1}',
        );

  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorThemes[colorCustom],
      textTheme: _typographyThemes[typographyCustom],
    );
  }
}

