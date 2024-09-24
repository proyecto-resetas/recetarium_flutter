import 'package:flutter/material.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:resetas/providers/recipes_provider.dart';

class ViewRecipes extends StatelessWidget {

  const ViewRecipes( {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final viewRecipesState = Provider.of<ViewRecipesProvider>(context);

    IconData icon;
    if (viewRecipesState.setFavorite != null) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.secondaryContainer,
        title: const Text('All of the Recipes'),
      ),
      body: Column(
        children: [
          SizedBox(     
            child: Card(
              margin: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      child: const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child:  Image(
                          image: NetworkImage(
                              'https://content.elmueble.com/medio/2024/02/23/pollo-curry-manzana_012ed92b_00535188_240223081823_900x900.jpg',
                              scale: 10.0),
                        ),
                      )),
                  Container(
                      width: 130,
                      height: 110, 
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pollo con pan',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          // SizedBox(height: 50,),
                         Wrap(
                           children: [
                            Icon(Icons.attach_money, size: 20),
                             Text('45,000'),
                           ],
                         )
                        ],
                      )

                            ),
                  Container(
                    height: 110, 
                    width: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end, // Alinea hacia abajo (parte inferior)
                      crossAxisAlignment: CrossAxisAlignment.end, // Alinea el contenido al final horizontalmente
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
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}

  // const Text('Calificación:'),
            // RatingBar.builder(             
            //   itemSize: 20,
            //   initialRating: 3, // Valor inicial
            //   minRating: 1, // Calificación mínima
            //   direction: Axis.horizontal, // Dirección horizontal
            //   allowHalfRating: true, // Permite media estrella
            //   itemCount: 3, // Número de estrellas
            //   itemPadding:const EdgeInsets.symmetric(horizontal: 2.0),
            //    itemBuilder: (context, _) => const Icon(
            //     Icons.star,
            //     color: Colors.amber,
            //   ),
            //   onRatingUpdate: (rating) {
            //     print(rating); // Actualiza la calificación en tiempo real
            //   },
            // ),