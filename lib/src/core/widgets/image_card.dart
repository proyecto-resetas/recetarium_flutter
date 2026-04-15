import 'package:flutter/material.dart';

class MyImage extends StatelessWidget {
  final String? imageUrl;

  const MyImage(this.imageUrl, {super.key} );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: size.width * 0.18,
        height: size.height * 0.14,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 40,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl!,
        width: size.width * 0.18, 
        height: size.height * 0.14,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            width: size.width * 0.18,
            height: size.height * 0.14,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
       
          return Container(
            width: size.width * 0.18,
            height: size.height * 0.14,
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
