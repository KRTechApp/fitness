import 'package:flutter/material.dart';

Widget customCard({required Widget child, required double radius, required double blurRadius}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          //<-- SEE HERE
          color: Colors.black.withOpacity(0.10),
          blurRadius: blurRadius,
        ),
      ],
    ),
    child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child),
  );
}
