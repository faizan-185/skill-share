import 'package:flutter/material.dart';


class Tag extends StatefulWidget {
  final String title;
  const Tag({Key? key, required this.title}) : super(key: key);

  @override
  State<Tag> createState() => _TagState();
}

class _TagState extends State<Tag> {
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(widget.title),
      deleteIcon: Icon(Icons.cancel, color: Colors.red,),
      onDeleted: () {
        // Handle tag removal
      },
    );
  }
}
