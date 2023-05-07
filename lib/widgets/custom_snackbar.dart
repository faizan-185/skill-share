import 'package:flutter/material.dart';


SnackBar successSnackBar(text){
  return SnackBar(
    dismissDirection: DismissDirection.horizontal,
    elevation: 3.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    content: Text(text, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
    backgroundColor: Colors.grey[300],
  );
}

SnackBar errorSnackBar(text){
  return SnackBar(
    dismissDirection: DismissDirection.horizontal,
    elevation: 3.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    content: Text(text, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
    backgroundColor: Colors.grey[300],
  );
}
