import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      icon = Icons.favorite_border;
    } else {
      icon = Icons.favorite;
    }

    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

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
              width: 110,
              height: 140,
              padding: const EdgeInsets.all(10),
              child: _MyImage(recipes.imageUrl),
            ),
            Expanded(
              // Para ocupar el espacio disponible
              child: Container(
                height:140,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      maxLines: 1,
                      recipes.nameRecipe,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      recipes.descriptionRecipe,
                      maxLines: isLandscape ? 2 : 2, // Cambia según orientación
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                     Text(
                      recipes.category,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    Text('\$${recipes.price.toString()}'),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 130,
              width: 40,
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

  const _MyImage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: size.width * 0.18, // Ajusta el ancho de la imagen
        height: size.height * 0.12, // Ajusta la altura de la imagen
        fit: BoxFit.cover, // Ajusta la imagen dentro del contenedor
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

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
            width: size.width * 0.18,
            height: size.height * 0.12,
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
