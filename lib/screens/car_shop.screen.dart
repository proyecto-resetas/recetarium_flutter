import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/providers/car_shop_provider.dart';
import 'package:resetas/widgets/image_card.dart';

class CarShop extends StatelessWidget {
    const CarShop({super.key});

 @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<CarShopProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: shopProvider.shoppingList.isEmpty
          ? const Center(
              child: Text('No recipes in the cart'),
            )
          : ListView.builder(
              itemCount: shopProvider.shoppingList.length,
              itemBuilder: (context, index) {
                final RecipesModel recipe = shopProvider.shoppingList[index];

                 return Card(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 110,
              height: 100,
              padding: const EdgeInsets.all(10),
              child: MyImage(recipe.imageUrl),
            ),
            Expanded(
              // Para ocupar el espacio disponible
              child: Container(
                height:100,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      maxLines: 1,
                      recipe.nameRecipe,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                     Text(
                      recipe.category,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    Text('\$${recipe.price.toString()}'),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 90,
              width: 40,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, 
                crossAxisAlignment: CrossAxisAlignment
                    .end, 
                children: [
                  IconButton(
                    icon: const Icon(Bootstrap.bag_dash_fill),
                    onPressed: () {
                      shopProvider.removeFromCart(recipe);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${recipe.nameRecipe} removed from cart')),
                      );
                    },
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      );          
                
     },
    ),
  bottomSheet: Container(
  color: Colors.transparent, // Hace el fondo del Container transparente
  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
  height: 50,
  width: 300,
  child: ElevatedButton.icon(
    onPressed: () {
       showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.3,
                  maxChildSize: 0.8,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          const Text(
                            'Payment',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Nombre en la tarjeta',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Número de tarjeta',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Expiración (MM/AA)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'CVC',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              
                              // Lógica para procesar el pago
                              Navigator.pop(context);
                            },
                            child: const Text('Pagar ahora'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
    },
    label: const Text('Buy with Wompi'),
    icon: const Icon(Bootstrap.shop_window),
    style: ElevatedButton.styleFrom(
    elevation: 0, // Quita la sombra del botón
    ),
  ),
),

   );

   
  }
}


