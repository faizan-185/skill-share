import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/static/user.dart';
import '../../theme.dart';
import '../../widgets/message_tile.dart';
import '../../widgets/my_drawer.dart';


class DiscussionRoom extends StatefulWidget {
  final String groupId;
  const DiscussionRoom({Key? key, required this.groupId}) : super(key: key);

  @override
  State<DiscussionRoom> createState() => _DiscussionRoomState();
}

class _DiscussionRoomState extends State<DiscussionRoom> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  bool loading = false;
  bool isTwo = false;
  String name = "";
  late Map<String, dynamic> group;
  Stream<QuerySnapshot>? chats;
  late Map<String, dynamic> user ;


  TextEditingController messageController = TextEditingController();


  Future<void> getGroupInfo(groupId) async {
    setState(() {
      loading = true;
    });
    DocumentReference documentReference = firestore.collection('groups').doc(
        groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
      setState(() {
        group = documentSnapshot.data() as Map<String, dynamic>;
      });
    }
    setState(() {
      loading = false;
    });
  }

  fetchChat(groupId) async {
    return firestore.collection('groups').doc(groupId).collection("messages")
        .orderBy("timestamp")
        .snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: Text("Discussions", style: textStylePrimary15,),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: kPrimaryColor,
            size: 30
        ),
      ),
      body: loading ? const Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Text("${group['group_name']}", style: titleText,),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Text("${group['group_details']}", style: subTitle,),
          ),
          const Divider(color: kPrimaryColor,),
          Expanded(
            child: StreamBuilder(
              stream: chats,
              builder: (context, AsyncSnapshot snapshot) {
                return snapshot.hasData
                    ? ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      message: snapshot.data.docs[index]['context'],
                      sender: snapshot.data.docs[index]['sender_name'],
                      sentByMe: MyUser.uid ==
                          snapshot.data.docs[index]['sender_uid'],
                      timestamp: snapshot.data.docs[index]['timestamp'].millisecondsSinceEpoch,
                    );
                  },
                )
                    : Container();
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 18),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.grey[700],
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Colors.white,
                            fontSize: 16),
                        border: InputBorder.none,
                      ),
                    )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () async {
                    await sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "context": messageController.text,
        "sender_name": MyUser.firstName,
        "sender_uid": MyUser.uid,
        "timestamp": DateTime
            .now(),
      };
      await firestore.collection('groups').doc(widget.groupId).update({'updated_at': DateTime.now()});
      await firestore.collection('groups').doc(widget.groupId).
      collection("messages").add(chatMessageMap).then((value) =>
          setState(() {
            messageController.text = "";
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }));
    }
  }


  @override
  void initState() {
    super.initState();
    getGroupInfo(widget.groupId);
    fetchChat(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
  }
}
