import 'package:flutter/material.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:const Text('name Profile'),
        ),
      
        body: const Center(
          
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
              padding:EdgeInsets.all(8.0),
              child: CircleAvatar(backgroundImage: NetworkImage('https://img.freepik.com/psd-gratis/3d-ilustracion-persona-gafas-sol_23-2149436188.jpg?t=st=1726781827~exp=1726785427~hmac=3500ff65846a53afb05f3badab4c878b926f7cf0a6631264c6b4b4582e4b9e67&w=1060')) ),
              Text('John Doe'),
              Text('Age: 30'),
              Text('Location: New York'),
              SizedBox(height: 16),
              Text('About Me'),
              Text('I am a software engineer with a passion for technology.'),
            ],
          ),
        ),
  
    );

    
  }
}