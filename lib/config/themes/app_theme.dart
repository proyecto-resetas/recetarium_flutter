// ignore: file_names
import 'package:flutter/material.dart';

// Colores personalizados
const _colorCustoms = Color.fromRGBO(254, 166, 33, 1);
const customPrimaryColor = Color(0xFFFFA740); // Morado
const customSecondaryColor = Color(0xFF114946); // Verde agua
const customTertiaryColor = Color(0xFF0E8544); // Gris oscuro
const customBackgroundColor = Color(0xFFF5F5F5); // Gris claro
const customSurfaceColor = Color(0xFFFFFFFF); // Blanco
const customErrorColor = Color(0xFFB00020); // Rojo
const customOnPrimaryColor = Color(0xFF80A69B); // Blanco para texto en fondo primario
const customOnSecondaryColor = Color(0xFF000000); 

ColorScheme customColorScheme = const ColorScheme(

  primary: customPrimaryColor,
  secondary: customSecondaryColor,
  tertiary: customTertiaryColor,
 // background: customBackgroundColor,
  surface: customSurfaceColor,
  error: customErrorColor,
  onPrimary: customOnPrimaryColor,
  onSecondary: customOnSecondaryColor,
 // onBackground: Colors.black, 
  onSurface: Colors.black, 
  onError: Colors.white, 
  brightness: Brightness.light, 
);

const List<Color> _colorThemes = [
  _colorCustoms,
  Color.fromARGB(255, 181, 151, 0),
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
      colorScheme: customColorScheme,
      //colorSchemeSeed: _colorThemes[colorCustom],
      textTheme: _typographyThemes[typographyCustom],
    );
  }
}

