import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_share/theme.dart';
import 'package:skill_share/utils/constants.dart';
import 'package:skill_share/utils/styles.dart';
import 'package:skill_share/widgets/custom_snackbar.dart';
import 'package:skill_share/widgets/tag.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:skill_share/models/static/user.dart';

import '../Dashboard/home.dart';


class ChooseInterests extends StatefulWidget {
  const ChooseInterests({Key? key}) : super(key: key);

  @override
  State<ChooseInterests> createState() => _ChooseInterestsState();
}

class _ChooseInterestsState extends State<ChooseInterests> {
  List<String> chosenInterests = [];
  String selectedInterest = "";
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool loading = false;


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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        actions: [
          TextButton(
            child: Text("Next", style: textButton,),
            onPressed: () async {
              if(chosenInterests.isNotEmpty)
                {
                  showLoadingDialog(context);
                  DocumentReference documentReference = firestore.collection('interests').doc(MyUser.uid);
                  await documentReference.set({
                    'my_interests': chosenInterests,
                  }).then((value) {
                  }).catchError((error) {
                  });
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                  );
                }
              else{
                ScaffoldMessenger.of(context).showSnackBar(errorSnackBar("Please select interests!"));
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Text("Choose Interests", style: titleText,),
              Text("Choose any 10 interest to see related information.", style: subTitle,),
              const SizedBox(height: 20,),
              DropdownSearch<String>.multiSelection(
                mode: Mode.MENU,
                showSelectedItems: true,
                showClearButton: true,
                showSearchBox: true,
                items: skills,
                selectedItems: chosenInterests,
                dropdownSearchDecoration: const InputDecoration(
                  labelText: "Choose Interests",
                  hintText: "Search ...",
                ),
                onChanged: (value) {
                  if (value.length > 10)
                    {
                      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar("Limit exceeded, not allowed more than 10."));
                    }
                  else
                    {
                      setState(() {
                        chosenInterests = value;
                      });
                    }
                  },
              ),
            ],
          ),
        ),
      )
    );
  }
}
