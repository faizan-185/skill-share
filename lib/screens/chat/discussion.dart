import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_share/screens/chat/discussion_chat_room.dart';
import 'package:skill_share/widgets/loader.dart';

import '../../theme.dart';
import '../../widgets/my_drawer.dart';


class Discussion extends StatefulWidget {
  const Discussion({Key? key}) : super(key: key);

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> list = <String>['General', 'Issue', 'Discussion', 'Question'];
  bool loading = false;
  List<Map<String, dynamic>> groups = [];
  String tag = "General";


  fetchDiscussion() async {
    setState(() {
      loading = true;
    });
    CollectionReference groupsRef =  FirebaseFirestore.instance.collection('groups');
    Query query = groupsRef.where('is_two', isEqualTo: false);
    await query.get().then((QuerySnapshot snapshot) async {
      List<QueryDocumentSnapshot> matchingDocs = snapshot.docs;
      matchingDocs.forEach((element) async {
        Map<String, dynamic> group = element.data() as Map<String, dynamic>;
        setState(() {
          group['id'] = element.id;
          groups.add(group);
        });
      });
    });
    setState(() {
      loading = false;
    });
  }

  showCreateDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _messageController = TextEditingController();
    String _tag = "General";

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return an AlertDialog
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                height: 450,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text("Create a discussion", style: textStylePrimary15,),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter Title',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Details',
                          hintText: 'Enter your details',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter  details';
                          }
                          if (value.length < 10) {
                            return 'Detail must be at least 10 characters long';
                          }
                          return null;
                        },
                      ),
                      RadioListTile<String>(
                        dense: true,
                        title: const Text('General'),
                        value: "General",
                        groupValue: _tag,
                        onChanged: (String? value) {
                          setState(() {
                            _tag = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        dense: true,
                        title: const Text('Discussion'),
                        value: "Discussion",
                        groupValue: _tag,
                        onChanged: (String? value) {
                          setState(() {
                            _tag = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        dense: true,
                        title: const Text('Issue'),
                        value: "Issue",
                        groupValue: _tag,
                        onChanged: (String? value) {
                          setState(() {
                            _tag = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        dense: true,
                        title: const Text('Question'),
                        value: "Question",
                        groupValue: _tag,
                        onChanged: (String? value) {
                          setState(() {
                            _tag = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            showLoadingDialog(context);
                            await FirebaseFirestore.instance.collection('groups').add({
                              "group_name": _nameController.text,
                              "is_two": false,
                              "group_details": _messageController.text,
                              "tag": _tag,
                              "created_at": DateTime.now(),
                              "updated_at": DateTime.now(),

                            }).then((docRef) async {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              groups = [];
                              await fetchDiscussion();
                              print('Document created with uid: ${docRef.id}');
                            }).catchError((error) {
                              print('Error creating document: $error');
                            });
                          }
                        },
                        child: Text('Create'),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    fetchDiscussion();
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
              tag = "General";
            });
            fetchDiscussion();
          }, icon: const Icon(Icons.refresh, color: kPrimaryColor, size: 25,))
        ],
      ),
      body: loading ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),) :
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Discussions", style: titleText,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Add Filters"),
                    SizedBox(width: 20,),
                    DropdownButton<String>(
                      value: tag,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? value) async {
                        setState(() {
                          groups = [];
                          tag = value!;
                        });
                        await fetchDiscussion();
                        List<Map<String, dynamic>>newGroups = [];
                        groups.forEach((g) {
                          if(g['tag'] == tag) {
                            newGroups.add(g);
                          }
                        });
                        setState(() {
                          groups = newGroups;
                        });
                      },
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                groups.isNotEmpty ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      child: ListTile(
                        trailing: Text("# ${groups[index]["tag"]}"),
                        title: Text(groups[index]["group_name"], style: textStylePrimary15),
                        subtitle: Text(groups[index]["group_details"]),
                          isThreeLine: true,
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiscussionRoom(groupId: groups[index]['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ) : const Center(child: Text("No Discussions Are Created!"),)
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            showCreateDialog(context);
        },
        backgroundColor: kPrimaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
