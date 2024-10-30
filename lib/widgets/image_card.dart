import 'package:flutter/material.dart';

class MyImage extends StatelessWidget {
  final String imageUrl;

  const MyImage(this.imageUrl, {super.key} );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: size.width * 0.18, 
        height: size.height * 0.12,
        fit: BoxFit.cover,
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
       
          return Container(
            width: size.width * 0.18,
            height: size.height * 0.12,
            color: Colors.grey.shade300, 
            alignment: Alignment.center,
            child: const Icon(
              Icons.error, 
              color: Colors.red,
              size: 40,
            ),
          );
        },
      ),
    );
  }
}
