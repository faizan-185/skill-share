import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_share/models/static/user.dart';
import 'package:skill_share/screens/User/profile_view.dart';
import 'package:skill_share/theme.dart';
import 'package:skill_share/widgets/loader.dart';
import 'package:skill_share/widgets/my_drawer.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late List<String> skills = [];
  late List<String> interests = [];
  late List<Map<String, dynamic>> users = [];
  bool loading = false;
  late final videoPlayerController;
  late final chewieController;
  List<String> list = <String>['My State', 'My City', 'My Country'];
  String filter = "My Country";

  Future<void> fetchUser(uid) async {
    setState(() {
      loading = true;
    });

    DocumentReference documentReference2 = firestore.collection('interests').doc(uid);
    DocumentSnapshot documentSnapshot2 = await documentReference2.get();
    if (documentSnapshot2.exists) {
      var data  = documentSnapshot2.data() as Map<String, dynamic>;
      for( String i in data["my_interests"]) {
        interests.add(i);
      }
    }

    CollectionReference skillsRef =  FirebaseFirestore.instance.collection('skills');
    Query query = skillsRef.where('my_skills', arrayContainsAny: interests);
    await query.get().then((QuerySnapshot snapshot) async {
      List<QueryDocumentSnapshot> matchingDocs = snapshot.docs;
      matchingDocs.forEach((element) async {
        List<String> my_skills = [];
        if(element.id != MyUser.uid)
          {
            late Map<String, dynamic> user;
            for( String i in element["my_skills"])
            {
              my_skills.add(i);
            }
            DocumentReference documentReference = firestore.collection('users').doc(element.id);
            DocumentSnapshot documentSnapshot = await documentReference.get();
            if (documentSnapshot.exists) {
              user = documentSnapshot.data() as Map<String, dynamic>;
              user['skills'] = my_skills;
              user['uid'] = element.id;
              DocumentReference documentReference4 = firestore.collection('multimedia').doc(element.id);
              DocumentSnapshot documentSnapshot4 = await documentReference4.get();
              List<String> images = [];
              List<String> videos = [];
              if (documentSnapshot4.exists) {
                var data  = documentSnapshot4.data() as Map<String, dynamic>;
                for( String i in data["images"])
                {
                  images.add(i);
                }
                for( String i in data["videos"])
                {
                  videos.add(i);
                }
                user["images"] = images;
                user["videos"] = videos;
              }
              DocumentReference documentReference3 = firestore.collection('reviews').doc(element.id);
              DocumentSnapshot documentSnapshot3 = await documentReference3.get();
              double ratings = 0;
              if (documentSnapshot3.exists) {
                var data  = documentSnapshot3.data() as Map<String, dynamic>;
                for( Map<String, dynamic> i in data["my_reviews"])
                {
                  ratings += i['rating'];
                }
                ratings = ratings / data["my_reviews"].length;
              }

              setState(() {
                user['ratings'] = ratings;
                if(user['country'].toLowerCase() == MyUser.country.toLowerCase()){
                  users.add(user);
                }
              });
            }
          }
      });
    });
    await Future.delayed(const Duration(seconds: 4));

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
      ),
      body: loading ? const Center(child: CircularProgressIndicator(color: kPrimaryColor,)) :SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Skill Share", style: titleText,),
              Text("Top Skills Picked For You", style: subTitle,),
              const SizedBox(height: 10,),
              users.isEmpty ? const Text("") : const Text("Long Press on name to view profile", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Search Skills By: "),
                  SizedBox(width: 20,),
                  DropdownButton<String>(
                    value: filter,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? value) async {
                      setState(() {
                        users = [];
                        interests = [];
                        skills = [];
                        filter = value!;
                      });
                      await fetchUser(MyUser.uid).then((value) async {
                        List<Map<String, dynamic>>newUsers = [];
                        if(filter == "My Country"){
                          users.forEach((u) {
                            if(u['country'].toLowerCase() == MyUser.country.toLowerCase()) {
                              newUsers.add(u);
                            }
                          });
                        }
                        else if(filter == "My State"){
                          users.forEach((u) {
                            if(u['state'].toLowerCase() == MyUser.state.toLowerCase()) {
                              newUsers.add(u);
                            }
                          });
                        }
                        else if(filter == "My City"){
                          users.forEach((u) {
                            if(u['city'].toLowerCase() == MyUser.city.toLowerCase()) {
                              print("match");
                              newUsers.add(u);
                            }
                          });
                        }
                        setState(() {
                          users = newUsers;
                        });
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
              const SizedBox(height: 20,),
              users.isEmpty ? const Center(child: Text("We cannot find skills matching your interests."),) : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index){
                  List<String> images = users[index]['images'].isEmpty ? [users[index]['cover_url']] : users[index]['images'];
                  List<String> my_skills = users[index]['skills'];
                  return Card(
                    elevation: 3,
                    child: Container(
                      padding: const EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child: Column(
                        children: [
                          CarouselSlider(
                            items: images.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Image.network(i, fit: BoxFit.fitWidth, width: MediaQuery.of(context).size.width,);
                                },
                              );
                            }).toList(),
                              options: CarouselOptions(
                                height: 150,
                                aspectRatio: 16/9,
                                viewportFraction: 0.85,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                enlargeCenterPage: true,
                                enlargeFactor: 0.3,
                                scrollDirection: Axis.horizontal,
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, left: 20),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: kPrimaryColor,),
                                const SizedBox(width: 10,),
                                Text("Lives in ${users[index]['city']}")
                              ],
                            ),
                          ),
                          GestureDetector(
                            onLongPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewProfile(uid: users[index]['uid']),
                                ),
                              );
                            },
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(users[index]['profile_url']),
                              ),
                              title: Text("${users[index]['first_name']} ${users[index]['last_name']}", style: textStylePrimary15Light,),
                              subtitle: Text(users[index]['bio']),
                              trailing: SizedBox(
                                  width: 35,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text("${users[index]['ratings'].toStringAsFixed(1)}", style: textStylePrimary12),
                                          const Icon(Icons.star, color: Colors.amber, size: 15,)
                                        ],
                                      ),
                                      Icon(Icons.arrow_drop_down, color: kPrimaryColor, size: 20,)
                                    ],
                                  )
                              ),
                              children: [
                                Wrap(
                                  spacing: 1.0, // horizontal space between chips
                                  children: my_skills.map((option) => Chip(
                                      label: Text(option, style: TextStyle(fontSize: 10),),
                                      padding: EdgeInsets.all(0)
                                  )).toList(),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUser(MyUser.uid);
  }
}
