import 'package:flutter/material.dart';

class PopularTemple extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const PopularTemple({
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300, // Add fixed width
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        height: 200,
      ),
    );
  }
}
