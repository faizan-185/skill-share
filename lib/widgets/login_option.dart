import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skill_share/screens/Dashboard/home.dart';
import 'package:skill_share/screens/User/choose_interests.dart';
import 'package:skill_share/screens/User/onboarding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_share/models/static/user.dart';

class LoginOption extends StatefulWidget {
  @override
  State<LoginOption> createState() => _LoginOptionState();
}

class _LoginOptionState extends State<LoginOption> {
  bool loading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        BuildButton(
          iconImage: loading
              ? const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(color: Colors.black),
                )
              :  const Image(
            height: 30,
            width: 30,
            image: AssetImage('images/google.png'),
          ),
          textButton: '   Google',
          onTap: () async {
            setState(() {
              loading = true;
            });
            GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
            GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
            AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth?.accessToken,
              idToken: googleAuth?.idToken
            );
            UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);

            DocumentReference documentReference = firestore.collection('users').doc(user.user!.uid);
            DocumentSnapshot documentSnapshot = await documentReference.get();
            if (documentSnapshot.exists) {
              MyUser.uid = user.user!.uid;
              MyUser.firstName = documentSnapshot.get('first_name');
              MyUser.lastName = documentSnapshot.get('last_name');
              MyUser.address = documentSnapshot.get('address');
              MyUser.dob = documentSnapshot.get('dob');
              MyUser.phone = documentSnapshot.get('phone');
              MyUser.profileUrl = documentSnapshot.get('profile_url');
              MyUser.coverUrl = documentSnapshot.get('cover_url');
              MyUser.gender = documentSnapshot.get('gender');
              MyUser.city = documentSnapshot.get('city');
              MyUser.state = documentSnapshot.get('state');
              MyUser.country = documentSnapshot.get('country');
              MyUser.zip = documentSnapshot.get('zip');
              MyUser.email = documentSnapshot.get('email');
              MyUser.bio = documentSnapshot.get('bio');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OnboardingScreen(),
                ),
              );
            }
            setState(() {
              loading = false;
            });
          },
        ),
      ],
    );
  }
}

class BuildButton extends StatelessWidget {
  final Widget iconImage;
  final String textButton;
  final VoidCallback onTap;
  BuildButton({required this.iconImage, required this.textButton, required this.onTap});
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: mediaQuery.height * 0.06,
        width: mediaQuery.width * 0.80,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconImage,
            const SizedBox(
              width: 5,
            ),
            Text(textButton, style: const TextStyle(fontSize: 20),),
          ],
        ),
      ),
    );
  }
}
