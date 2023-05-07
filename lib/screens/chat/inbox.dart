import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_share/screens/chat/chat_room.dart';

import '../../models/static/user.dart';
import '../../theme.dart';
import '../../widgets/my_drawer.dart';

class Inbox extends StatefulWidget {
  const Inbox({Key? key}) : super(key: key);

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool loading = false;
  List<Map<String, dynamic>> groups = [];

  fetchGroups() async {
    setState(() {
      loading = true;
    });
    CollectionReference groupsRef =  FirebaseFirestore.instance.collection('groups');
    Query query = groupsRef.where('members', arrayContainsAny: [MyUser.uid]).where('is_two', isEqualTo: true);
    await query.get().then((QuerySnapshot snapshot) async {
      List<QueryDocumentSnapshot> matchingDocs = snapshot.docs;
      matchingDocs.forEach((element) async {
        Map<String, dynamic> group = element.data() as Map<String, dynamic>;
        String uid = "";
        group['members'].forEach((member) async {
          if(member != MyUser.uid){
            uid = member;
            DocumentReference documentReference = firestore.collection('users').doc(uid);
            DocumentSnapshot documentSnapshot = await documentReference.get();
            if (documentSnapshot.exists) {
              Map<String, dynamic> user = documentSnapshot.data() as Map<String, dynamic>;
              group['user_name'] = "${user['first_name']} ${user['last_name']}";
              group['profile_url'] = user['profile_url'];
              group['id'] = element.id;
              setState(() {
                groups.add(group);
              });
            }
          }
        });

      });
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const MyDrawer(),
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          elevation: 0,
          iconTheme: const IconThemeData(
              color: kPrimaryColor,
              size: 30
          ),
          actions: [
            IconButton(onPressed: ()async{
              setState(() {
                groups = [];
              });
              fetchGroups();
            }, icon: const Icon(Icons.refresh, color: kPrimaryColor, size: 25,))
          ],
        ),
        body: loading ? const Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Inbox", style: titleText,),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: groups.length,
                  itemBuilder: (BuildContext context, int index){
                    return Card(
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(groups[index]["profile_url"]),
                        ),
                        title: Text(groups[index]['user_name'], style: textStylePrimary15,),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        )
    );
  }

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }
}
