
import 'package:flutter/material.dart';

class MyRecipesFavorites extends StatefulWidget {

  
  @override
  _CreateDynamicInputsState createState() => _CreateDynamicInputsState();
}

class _CreateDynamicInputsState extends State<MyRecipesFavorites> {
  // Lista para almacenar los controladores de los inputs
  final List<TextEditingController> _controllersD = [];
  final List<TextEditingController> _controllersT = [];

  @override
  void initState() {
    super.initState();
    _controllersD.add(TextEditingController()); // Agregamos un controlador por defecto
    _controllersT.add(TextEditingController()); // Agregamos un controlador por defecto
  }

  // Función para agregar un nuevo input dinámico
  void _addInput() {
    setState(() {
      _controllersD.add(TextEditingController()); // Agrega un nuevo controlador de texto
      _controllersT.add(TextEditingController()); // Agrega un nuevo controlador de texto
    });
  }

  // Función para recoger los valores de los inputs y almacenarlos en un objeto o lista
  List<Map<String, dynamic>> _collectInputValues() {
    List<Map<String, dynamic>> steps = [];

    for (int i = 0; i < _controllersD.length; i++) {
      String description = _controllersD[i].text;
      String time = _controllersT[i].text;

      steps.add({
        'description': description,
        'time': time,
      });
    }

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Inputs Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _controllersD.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _controllersD[index],
                        decoration: InputDecoration(
                          labelText: 'Step ${index + 1}, description',
                        ),
                      ),
                      TextFormField(
                        controller: _controllersT[index],
                        decoration: InputDecoration(
                          labelText: 'Time',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addInput, // Llama a la función para agregar nuevos inputs
              child:const Text('Agregar Input'),
            ),
            ElevatedButton(
              onPressed: () {
                // Al presionar este botón, recoge los valores y muestra el resultado
                List<Map<String, dynamic>> steps = _collectInputValues();
                print(steps); // Puedes hacer lo que desees con estos valores, como guardarlos o enviarlos a un API
              },
              child: const Text('Guardar Steps'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Libera los controladores de texto cuando ya no se necesiten
    for (var controller in _controllersD) {
      controller.dispose();
    }
    for (var controller in _controllersT) {
      controller.dispose();
    }
    super.dispose();
  }
}
