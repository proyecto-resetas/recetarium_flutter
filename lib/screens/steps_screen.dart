import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/providers/steps_provider.dart';

class StepsScreen extends StatelessWidget {

  final RecipesModel recipe;
  final PageController _pageController = PageController(initialPage: 0);

  StepsScreen(
  {super.key,
  required this.recipe}
  );

  @override
  Widget build(BuildContext context) {
    final stepsProvider = Provider.of<StepsProvider>(context);

    final pageTotalSteps = recipe.steps.length;

     // Resetea el estado del PageController y el estado del Provider
 WidgetsBinding.instance.addPostFrameCallback((_) {
      if (stepsProvider.currentPage == 0) {
        final int timeInMilliseconds = stepsProvider.timeStringToMilliseconds(recipe.steps[0].time);
        stepsProvider.startAutoSlide(_pageController, pageTotalSteps, timeInMilliseconds);
      }
          });

    return Scaffold(
      appBar: AppBar(
        title:const Text('Steps'),
      ),
      body: Padding(
         padding: const EdgeInsets.all(16.0),
        child: Column(
          children:[
               Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                 stepsProvider.setCurrentPage(page);
                  // Obtén el tiempo del paso actual y vuelve a iniciar el auto-slide
                  final int newTimeInMilliseconds = stepsProvider.timeStringToMilliseconds(recipe.steps[page].time);
                  stepsProvider.startAutoSlide(_pageController, pageTotalSteps, newTimeInMilliseconds);
              },
              physics: BouncingScrollPhysics(), // Desplazamiento manual suave
              children: [
                   ...recipe.steps.map((step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: 
                  _buildPage(description: step.description, time: step.time),
                )),
              ],
            ),
          ),
          _buildIndicator(context, pageTotalSteps),
          ]
        ),
      )
    );
  }

    Widget _buildPage({required String description, required String time}) {
    return Container(
      child: Column(
        children:[
          Text(time),
          Text(
          description,
          style: TextStyle(fontSize: 32),
        ),
        ] 
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, pageTotalSteps) {
    final stepsProvider = Provider.of<StepsProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageTotalSteps, (index) {
        return Container(
          margin: EdgeInsets.all(4),
          width: stepsProvider.currentPage == index ? 12 : 8,
          height: stepsProvider.currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: stepsProvider.currentPage == index ? Colors.black : Colors.grey,
          ),
        );
      }),
    );
  }
}

