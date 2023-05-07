import 'package:flutter/material.dart';


showLoadingDialog(BuildContext context) {
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      // return an AlertDialog
      return AlertDialog(
        content: SizedBox(
          height: 90.0,
          width: 50,
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Please Wait!")
                ],
              )
          ),
        ),
      );
    },
  );
}