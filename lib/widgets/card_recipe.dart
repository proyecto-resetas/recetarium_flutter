import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:resetas/models/entities/recipes.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/providers/recipes_provider.dart';
import 'package:resetas/screens/recipes_details.screen.dart';

class CardRecipe extends StatelessWidget {
  final RecipesModel recipes;

  const CardRecipe({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final viewRecipesState = Provider.of<ViewRecipesProvider>(context);

    IconData icon;
    if (viewRecipesState.setFavorite != null) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return InkWell(
      // Detecta el toque en la Card
      onTap: () {
        // Navega al nuevo screen dinámico con la información de la receta
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipes),
          ),
        );
      },
      child: Card(
         clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                child: _MyImage(recipes.imageUrl)
                ),
            Container(
                width: 130,
                height: 130,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(recipes.nameRecipe,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)
                    ),
                    Text(
                    recipes.descriptionRecipe,
                    maxLines: 2,  // Limita el número de líneas visibles
                    overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: Colors.black54), // Muestra '...' cuando se corta
                    ),
                   //  SizedBox(height: 20,),
                    Wrap(
                      children: [
                        const Icon(Icons.attach_money, size: 20),
                        Text(recipes.price),
                      ],
                    )
                  ],
                )),
            SizedBox(
              height: 130,
              width: 85,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Alinea hacia abajo (parte inferior)
                crossAxisAlignment: CrossAxisAlignment
                    .end, // Alinea el contenido al final horizontalmente
                children: [
                  IconButton(
                    onPressed: () {
                      // Acción del botón
                    },
                    icon: Icon(icon), // Puedes cambiar el ícono
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class _MyImage extends StatelessWidget {
 
  final String imageUrl;

 const _MyImage(
       this.imageUrl
    );

  @override
  Widget build(BuildContext context) {


    final size = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius : BorderRadius.circular(10),
      child: Image.network(
          imageUrl,
          width: size.width * 0.18, // Ajusta el ancho de la imagen
          height: size.height * 0.12, // Ajusta la altura de la imagen
          fit: BoxFit.cover, // Ajusta la imagen dentro del contenedor
          loadingBuilder:(context, child, loadingProgress) {
            if(loadingProgress == null) return child;

            return Container(
             width: size.width * 0.18,
            height: size.height * 0.12,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(), 
        
            );
          },

          errorBuilder: (context, error, stackTrace) {
          // Manejador de errores si la imagen no se puede cargar
          return Container(
            width: size.width * 0.2,
            height: size.height * 0.10,
            color: Colors.grey.shade300, // Color de fondo en caso de error
            alignment: Alignment.center,
            child: const Icon(
              Icons.error, // Ícono que muestra el error
              color: Colors.red,
              size: 40,
            ),
          );
        },
        ),
      );
      
  }
}