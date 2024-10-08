import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/providers/auth_provider.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
          final authProvider = Provider.of<AuthProvider>(context);
        final user = authProvider.user;

         // Verificar si el usuario es null
    if (user == null) {
      return const Center(child: Text("No se encontró información del usuario."));
    }

    return Scaffold(
        appBar: AppBar(
          title:const Text('Profile'),
        ),
      
        body:  SingleChildScrollView(
          child: Center(
            child: Column(   
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: _MyPhoto(user.photoUrl)
                  ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric( vertical: 30),
                    child: Column(
                      children:[
                          
                          Text('${user.username} ${user.lastname}'),
                          Text(user.phone),
                          Text(user.email),
                          Text('Location: ${user.country}, ${user.city}'),
                          const SizedBox(height: 16),
                          const Text(' '),
                          const Text('recetas favoritas'),
                          const Text('chefs favoritos'),
                      ]
                    ),
                  ),
                ),
                ElevatedButton.icon(onPressed: (){
                    authProvider.logout();
                    Navigator.pushReplacementNamed(context, '/login');
          
                }, label: const Text('Logout') , icon: const Icon(Icons.logout) ,)
              ]
            )
          ),
        ),
    );    
  }
}

class _MyPhoto extends StatelessWidget {
  final String imageUrl;

  const _MyPhoto(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(80),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover, // Ajusta la imagen dentro del contenedor
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            width: size.width * 0.2,
            height: size.height * 0.12,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Manejador de errores si la imagen no se puede cargar
          return Container(
            width: size.width * 0.18,
            height: size.height * 0.12,
            color: Colors.grey.shade300, // Color de fondo en caso de error
            alignment: Alignment.center,
            child: const Icon(Icons.person, size: 100, color: Colors.black38),
          );
        },
      ),
    );
  }
}