import 'package:flutter/material.dart';
import 'package:skill_share/models/static/user.dart';
import 'package:skill_share/screens/Auth/login.dart';
import 'package:skill_share/screens/Dashboard/home.dart';
import 'package:skill_share/screens/User/profile_view.dart';
import 'package:skill_share/screens/chat/inbox.dart';
import 'package:skill_share/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/chat/discussion.dart';


class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    setState(() {
      cover = MyUser.coverUrl;
      profile = MyUser.profileUrl;
    });
  }

  late String cover, profile;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              image: cover == '' ?
                      const DecorationImage(
                          image: AssetImage('images/dummy_cover.jpeg'),
                          fit: BoxFit.fitWidth
                      ) : DecorationImage(
                          image: NetworkImage(cover),
                          fit: BoxFit.fitWidth
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: kPrimaryColor, width: 3),
                      shape: BoxShape.circle
                    ),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProfile(uid: MyUser.uid,),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: profile == '' ? AssetImage('images/dummy_user.png') : NetworkImage(profile) as ImageProvider,
                        radius: 50,
                      ),
                    ),
                  ),
                ],
              )
            )
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: kPrimaryColor,),
            title: Text("Home", style: textButton,),
            onTap: (){
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline, color: kPrimaryColor,),
            title: Text("Inbox", style: textButton,),
            onTap: (){
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Inbox(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_outlined, color: kPrimaryColor,),
            title: Text("Discussions", style: textButton,),
            onTap: (){
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Discussion(),
                ),
              );
            },
          ),
          const Divider(
            thickness: 1,
            color: kPrimaryColor,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: kPrimaryColor,),
            title: Text("Sign Out", style: textButton,),
            onTap: () async {
              await _auth.signOut().then((value) {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LogInScreen()));
              });
            },
          ),

        ],
      ),
    );
  }
}
