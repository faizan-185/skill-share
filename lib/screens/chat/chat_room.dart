import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_share/models/static/user.dart';

import '../../theme.dart';
import '../../widgets/message_tile.dart';
import '../../widgets/my_drawer.dart';

class ChatRoom extends StatefulWidget {
  final String groupId;
  const ChatRoom({Key? key, required this.groupId}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  bool loading = false;
  bool isTwo = false;
  String name = "";
  List<Map<String, dynamic>> groupChat = [];
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
      var group = documentSnapshot.data() as Map<String, dynamic>;
        if(group['is_two']) {
          String other = "";
          group['members'].forEach((member) =>{
            if (member != MyUser.uid)
              {
                other = member
              }
          });
          DocumentReference documentReference = firestore.collection('users').doc(other);
          DocumentSnapshot documentSnapshot = await documentReference.get();
          if (documentSnapshot.exists) {
            setState(() {
              isTwo = group['is_two'];
              user = documentSnapshot.data() as Map<String, dynamic>;
            });
          }
        }
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
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: kPrimaryColor,
            size: 30
        ),
      ),
      body: loading ? const Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kPrimaryColor)
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(user['profile_url']),
              radius: 50,
            ),
          ),
          Text("${user['first_name']} ${user['last_name']}", style: titleText,),
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
        // getGroupInfo(widget.groupId);
      });
    });
  }
}