//import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/models/entities/user.dart';
import 'package:resetas/providers/auth_provider.dart';
 // Tu provider

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  // final TextEditingController country=TextEditingController();
  // final TextEditingController state=TextEditingController();
  // final TextEditingController city=TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


   // Nueva variable para almacenar el rol seleccionado
  String? _selectedRole;
  

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
   // final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
    
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/images/recetariumBorderLive.png', scale: 5,),
              Container(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Radio de los bordes
                //color: colors.primaryFixed,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                padding: const EdgeInsets.all(30.0), 
                width: 480.0,
                height: 900,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(labelText: 'Name',
                        border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(labelText: 'Apellido',
                         border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                              ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your LastName';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email',
                         border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                              ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Email';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: 'Password',
                         border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                              ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter of the Password';
                          }
                          return null;
                        },
                      ),
                       TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(labelText: 'Phone Number',
                         border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                              ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Phone Number';
                          }
                          return null;
                        },
                      ),
                       
                      // CountryStateCityPicker(
                      //   country: country,
                      //   state: state,
                      //   city: city,
                      //   dialogColor: const Color.fromARGB(255, 255, 255, 255),
                      //   textFieldDecoration:  InputDecoration(
                      //      border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(10)),
                      //     // Configura solo la línea inferior
                      //     suffixIcon: const Icon(Icons.keyboard_arrow_down),
                         
                      //     labelStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)), // Estilo de la etiqueta
                      //   ),
                      // ),
              
                       // Añadir el campo para seleccionar el tipo de usuario
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        decoration: InputDecoration(labelText: 'Who do you want to be?',
                        border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                              ),
                        borderRadius: BorderRadius.circular(20) ,
                        items: ['user', 'chef'].map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedRole = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a user type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            User credentials = User(
                              email: emailController.text,
                              password: passwordController.text,
                              userName: firstNameController.text,
                              lastName: lastNameController.text,
                              phone: phoneController.text,
                              // country: country.text,
                              // city: city.text,
                              country: '',
                              city: '',
                              role: _selectedRole!, 
                            );
                
                            bool success = await authProvider.register(credentials);
                
                            // Mostrar mensaje de éxito o fracaso del registro, y redireccionar según el tipo de usuario.
                            if (success) {
                              // Redirigir según el tipo de usuario
                            
                            print(authProvider.user!.role);
                              if (authProvider.user!.role == 'admin') {
                                Navigator.pushReplacementNamed(context, '/admin_home');
                              } else {
                                Navigator.pushReplacementNamed(context, '/home');
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Registro fallido')),
                              );
                            }
                          }
                        },
                        child:const Text('Registrarse'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child:const Text('Ya tienes una cuenta? Inicia sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
