import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_share/models/static/user.dart';
import 'package:skill_share/screens/User/profile_edit.dart';
import 'package:skill_share/screens/chat/chat_room.dart';
import 'package:skill_share/widgets/custom_snackbar.dart';
import 'package:skill_share/widgets/loader.dart';
import 'package:skill_share/widgets/primary_button.dart';
import 'package:skill_share/widgets/tag.dart';
import '../../theme.dart';
import '../../widgets/my_drawer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:transparent_image/transparent_image.dart';
import'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:skill_share/widgets/video_widget.dart';



class ViewProfile extends StatefulWidget {
  final String uid;
  const ViewProfile({Key? key, required this.uid}) : super(key: key);

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> user;
  late List<String> skills = [];
  late List<String> interests = [];
  late List<Map<String, dynamic>> reviews = [];
  late Map<String, List<String>> media = {'images': [], 'videos': []};
  late List<String> _allMedia;
  bool loading = false;
  int currentIndex = 0;
  late TextEditingController _review = TextEditingController();
  ScrollController _scroll = ScrollController();
  late double _rating;
  double _rating2 = 0.0;



  Future<void> fetchUser(uid) async {
    setState(() {
      loading = true;
    });
    DocumentReference documentReference = firestore.collection('users').doc(uid);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
        user = documentSnapshot.data() as Map<String, dynamic>;
    }
    DocumentReference documentReference1 = firestore.collection('skills').doc(uid);
    DocumentSnapshot documentSnapshot1 = await documentReference1.get();
    if (documentSnapshot1.exists) {
        var data  = documentSnapshot1.data() as Map<String, dynamic>;
        for( String i in data["my_skills"])
          {
            skills.add(i);
          }
    }
    DocumentReference documentReference2 = firestore.collection('interests').doc(uid);
    DocumentSnapshot documentSnapshot2 = await documentReference2.get();
    if (documentSnapshot2.exists) {
      var data  = documentSnapshot2.data() as Map<String, dynamic>;
      for( String i in data["my_interests"])
      {
        interests.add(i);
      }
    }
    DocumentReference documentReference3 = firestore.collection('reviews').doc(uid);
    DocumentSnapshot documentSnapshot3 = await documentReference3.get();
    if (documentSnapshot3.exists) {
      var data  = documentSnapshot3.data() as Map<String, dynamic>;
      for( Map<String, dynamic> i in data["my_reviews"])
      {
        reviews.add(i);
        _rating2 += i['rating'];
      }
    }
    DocumentReference documentReference4 = firestore.collection('multimedia').doc(uid);
    DocumentSnapshot documentSnapshot4 = await documentReference4.get();
    if (documentSnapshot4.exists) {
      var data  = documentSnapshot4.data() as Map<String, dynamic>;
      for( String i in data["images"])
      {
        media['images']!.add(i);
      }
      for( String i in data["videos"])
      {
        media['videos']!.add(i);
      }
    }

    final allItems = [...media['images']!, ...media['videos']!];
    final random = Random();
    allItems.shuffle(random);

    setState(() {
      loading = false;
      _allMedia = allItems;
    });
  }

  void changeIndex(index) {
    setState(() {
      _scroll.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: kPrimaryColor,
            size: 30
        ),
        actions: [
          MyUser.uid == widget.uid ? TextButton(
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(uid: widget.uid, user: user, userSkills: skills, userInterests: interests, media: media,),
                ),
              );
            },
              child: Text("Edit", style: textButton,),
          ) : Text("")
        ],
      ),
      body: loading ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : SingleChildScrollView(
        controller: _scroll,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Text("${user["first_name"]} ${user["last_name"]}", style: titleText,),
              const SizedBox(
                height: 20,
              ),
              RepaintBoundary(
                child: IndexedStack(
                  index: currentIndex,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  border: Border.all(
                                      color: Colors.grey,
                                      width: 3
                                  ),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: user['cover_url']!= "" ? NetworkImage(user['cover_url']) : const AssetImage("images/dummy_cover.jpeg") as ImageProvider,
                                  )
                              ),
                            ),
                            SizedBox(height: 90,),
                            user['bio'] == "" ?
                            Center(child: Text("No Bio To SHow", style: textStylePrimary12,)) :
                            Center(child: Text(user['bio'], style: textStylePrimary12,)),

                            const SizedBox(height: 20),
                            MyUser.uid != widget.uid ?
                                Center(child: SizedBox(width: 200,
                                  child: PrimaryButton(buttonText: Text(
                                    'Send Message',
                                    style: textButton.copyWith(color: kWhiteColor),
                                  ), onClick: () async {
                                      CollectionReference groupsRef =  FirebaseFirestore.instance.collection('groups');
                                      Query query = groupsRef.where('members', arrayContainsAny: [MyUser.uid, widget.uid]).where('is_two', isEqualTo: true);
                                      await query.get().then((QuerySnapshot snapshot) async {
                                        List<QueryDocumentSnapshot> matchingDocs = snapshot.docs;
                                        if (matchingDocs.isEmpty){
                                         await FirebaseFirestore.instance.collection('groups').add({
                                            "group_name": "",
                                            "members": [MyUser.uid, widget.uid],
                                            "is_two": true,
                                            "created_at": DateTime.now(),
                                            "updated_at": DateTime.now(),

                                          }).then((docRef) {
                                           print('Document created with uid: ${docRef.id}');
                                         }).catchError((error) {
                                           print('Error creating document: $error');
                                         });
                                        }
                                        else{
                                          bool exist = false;
                                          String elem = '';
                                          for (var element in matchingDocs)  {
                                            Map<String, dynamic> group =  element.data() as Map<String, dynamic>;
                                            List<String> myList = [MyUser.uid, widget.uid];
                                            List<String> otherList = [];
                                            group['members'].forEach((member) {
                                              otherList.add(member);
                                            });
                                            if (myList.length == otherList.length && myList.toSet().containsAll(otherList)) {
                                              exist = true;
                                              elem = element.id;
                                              break;
                                            }

                                            // if(otherList.length == myList.length ){
                                            //   for (var element in myList) {
                                            //     if(!otherList.contains(element)){
                                            //       exist = false;
                                            //     }
                                            //   }
                                            // }else{
                                            //   exist = false;
                                            // }
                                            //
                                            // if(exist){
                                            //   print("Found");
                                            //   print(group);
                                            //   break;
                                            // }

                                          }

                                          if(exist){

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatRoom(groupId: elem),
                                              ),
                                            );
                                          }
                                          else{
                                            print("nai");
                                            await FirebaseFirestore.instance.collection('groups').add({
                                              "group_name": "",
                                              "members": [MyUser.uid, widget.uid],
                                              "is_two": true
                                            }).then((docRef) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ChatRoom(groupId: docRef.id),
                                                ),
                                              );
                                            }).catchError((error) {
                                              print('Error creating document: $error');
                                            });
                                          }

                                        }
                                      });

                                  },),
                                )) :
                                const Center(),

                            const SizedBox(height: 20),
                            Row(
                              children: [
                                SizedBox(width: 100, child: Text("Email", style: textStylePrimary12)),
                                Flexible(child: Text(user['email'], style: textStylePrimary15Light)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(width: 100, child: Text("Phone", style: textStylePrimary12)),
                                Flexible(child: Text(user['phone'], style: textStylePrimary15Light)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(width: 100, child: Text("Age", style: textStylePrimary12)),
                                Flexible(child: Text("${DateTime.now().difference(DateTime.parse(user['dob'])).inDays ~/ 365} Years", style: textStylePrimary15Light)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(width: 100, child: Text("Lives In", style: textStylePrimary12)),
                                Flexible(child: Text(user['city'] + ", " + user['country'], style: textStylePrimary15Light)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text("Has Following Skills", style: textStylePrimary15,),
                            const SizedBox(height: 20),
                            skills.isNotEmpty ? Wrap(
                              spacing: 8.0, // spacing between the chips
                              children: skills.map((skill) {
                                return Chip(
                                  label: Text(skill),
                                  backgroundColor: Colors.grey[300],
                                );
                              }).toList(),
                            ) : Text("No skills were added!"),
                            const SizedBox(height: 10,),
                            MyUser.uid != widget.uid ?
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Rate My Profile", style: textStylePrimary15,),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: RatingBar.builder(
                                            initialRating: _rating,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            unratedColor: Colors.amber.withAlpha(50),
                                            itemCount: 5,
                                            itemSize: 50.0,
                                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              setState(() {
                                                _rating = rating;
                                              });
                                            },
                                            updateOnDrag: true,
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: TextFormField(
                                            controller: _review,
                                            readOnly: loading,
                                            obscureText: false,
                                            validator: (String? value) =>
                                            value!.isEmpty ? 'Review is required' : null,
                                            keyboardType: TextInputType.text,
                                            decoration: const InputDecoration(
                                              labelText: "Review",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.only(top: 20),
                                          child: PrimaryButton(buttonText: Text(
                                            'Send Review',
                                            style: textButton.copyWith(color: kWhiteColor),
                                          ), onClick: () async {
                                            if(_formKey.currentState!.validate())
                                              {
                                                showLoadingDialog(context);
                                                var review = {
                                                  'rating': _rating,
                                                  'review': _review.text,
                                                  'reviewer_uid': MyUser.uid,
                                                  'reviewer_name': '${MyUser.firstName} ${MyUser.lastName}',
                                                  'profile_url': MyUser.profileUrl
                                                };
                                                setState(() {
                                                    reviews.add(review);
                                                    _rating2 += _rating;
                                                });
                                                DocumentReference documentReference = firestore.collection('reviews').doc(widget.uid);
                                                await documentReference.set({
                                                  'my_reviews': reviews,
                                                }).then((value) {
                                                  ScaffoldMessenger.of(context).showSnackBar(successSnackBar("Review Sent!"));
                                                  setState(() {
                                                    _review.text = "";
                                                    _rating = 0;
                                                  });
                                                }).catchError((error) {
                                                });
                                                Navigator.pop(context);
                                              }
                                          },),
                                      )
                                    ],
                                  ),
                                ): const Center(),
                            const SizedBox(height: 20),
                            Text("${reviews.length} Reviews", style: textStylePrimary15,),
                            const SizedBox(height: 20),
                            reviews.isNotEmpty ? RatingBarIndicator(
                              rating: _rating2 / reviews.length,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 40.0,
                              unratedColor: Colors.amber.withAlpha(50),
                              direction: Axis.horizontal,
                            ) : SizedBox(),
                            const SizedBox(height: 20),
                            reviews.isNotEmpty ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: reviews.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  elevation: 2,
                                  child: ListTile(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewProfile(uid: reviews[index]['reviewer_uid'],),
                                        ),
                                      );
                                    },
                                    title: Text(reviews[index]['reviewer_name'], style: textStylePrimary12),
                                    leading: CircleAvatar(
                                      backgroundImage: reviews[index]['profile_url']!= "" ? NetworkImage(reviews[index]['profile_url']) : const AssetImage("images/dummy_user.png") as ImageProvider,
                                    ),
                                    subtitle: Text(reviews[index]['review']),
                                    trailing: SizedBox(width: 35, child: Row(children: [Text("${reviews[index]['rating']}", style: textStylePrimary12), Icon(Icons.star, color: Colors.amber, size: 15,)],)),
                                  ),
                                );
                              },
                            ) : Text("No Reviews To Show")
                          ],
                        ),
                        Positioned(
                          top: 120.0,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 3),
                                shape: BoxShape.circle
                            ),
                            child: CircleAvatar(
                              backgroundImage: user['profile_url']!= "" ? NetworkImage(user['profile_url']) : const AssetImage("images/dummy_user.png") as ImageProvider,
                            ),
                          ),
                        )
                      ],
                    ),
                    _allMedia.isNotEmpty ? Container(
                      height: MediaQuery.of(context).size.height,
                      child: MasonryGridView.builder(
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _allMedia.length,
                        itemBuilder: (context, index) {
                          final item = _allMedia[index];
                          return Container(
                            decoration: const BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(15))
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(15)),
                              child: item.contains('.mp4') ? VideoWidget(url: item) : FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: item,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }, gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      ),
                    ) : const Center(child: Text("No Media Content Available!"),)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: kPrimaryColor,),
            label: "Profile",
            activeIcon: Icon(Icons.account_circle_outlined, color: kSelectedColor,),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_outlined, color: kPrimaryColor),
            label: "Media",
            activeIcon: Icon(Icons.image_outlined, color: kSelectedColor,),
          ),
        ],
        currentIndex: currentIndex,
        selectedItemColor: kSelectedColor,
        onTap: changeIndex,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUser(widget.uid);
    _rating = 0.0;
  }
}
