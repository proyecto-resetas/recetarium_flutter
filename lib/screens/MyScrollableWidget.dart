// import 'dart:async';
// //import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:resetas/models/recipes_model.dart';

// class StepsScreen extends StatefulWidget {
//   final RecipesModel recipe;

//   const StepsScreen({super.key, required this.recipe});

//   @override
//   State<StepsScreen> createState() => _StepsScreenState();
// }

// class _StepsScreenState extends State<StepsScreen> {
//   int _currentStepIndex = 0;
//   bool _isPaused = false;
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _currentStepIndex);
//     _startStepTimer();
//   }

//   void _startStepTimer() async {
//     while (_currentStepIndex < widget.recipe.steps.length && !_isPaused) {
//       int timeForStep = widget.recipe.steps[_currentStepIndex].timeScreen;

//       if (!_isPaused && mounted) {
//         await Future.delayed(Duration(milliseconds: timeForStep));

//         if (mounted) {
//           _goToNextStep();
//         }
//       } else {
//         await Future.delayed(const Duration(milliseconds: 1000));
//       }
//     }
//   }

//   void _goToNextStep() {
//     if (_currentStepIndex < widget.recipe.steps.length - 1) {
//       setState(() {
//         _currentStepIndex++;
//         _pageController.animateToPage(
//           _currentStepIndex,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       });
//     } else {
//       _resetSteps();
//       _pauseTimer();
//     }
//   }

//   void _pauseTimer() {
//     setState(() {
//       _isPaused = true;
//     });
//   }

//   void _resumeTimer() {
//     setState(() {
//       _isPaused = false;
//     });
//     _startStepTimer();
//   }

//   void _resetSteps() {
//     setState(() {
//       _currentStepIndex = 0;
//       _pageController.jumpToPage(0);
//     });
//   }

//   @override
//   void dispose() {
//     _isPaused = true;
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pasos de la Receta'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: PageView.builder(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentStepIndex = index;
//                 });
//               },
//               itemCount: widget.recipe.steps.length,
//               itemBuilder: (context, index) {
//                 final step = widget.recipe.steps[index];
//                 return Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         step.description,
//                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'Tiempo: ${step.time} segundos',
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _isPaused ? _resumeTimer : _goToNextStep,
//                 child: Text(_isPaused ? 'Reanudar' : 'Siguiente'),
//               ),
//               const SizedBox(width: 20),
//               ElevatedButton(
//                 onPressed: _pauseTimer,
//                 child: Text(_isPaused ? 'Pausado' : 'Pausar'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/providers/payment_wompi_provider.dart';


class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final paymentWompiProvider = Provider.of<PaymentWompiProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Procesar Pago')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: paymentWompiProvider.amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Monto a pagar'),
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text('Acepto los términos y condiciones'),
              value: paymentWompiProvider.acceptTerms,
              onChanged: (bool? value) {
                paymentWompiProvider.toggleAcceptTerms(value ?? false);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: paymentWompiProvider.acceptTerms ? () {
          //      paymentWompiProvider.processPayment(paymentWompiProvider.amountController.text);
              } : null,
              child: Text('Pagar'),
            ),
          ],
        ),
      ),
    );
  }
}
