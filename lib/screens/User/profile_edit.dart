import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_share/models/static/user.dart';
import 'package:skill_share/screens/User/profile_view.dart';
import 'package:skill_share/widgets/custom_snackbar.dart';
import 'package:skill_share/widgets/loader.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../theme.dart';
import '../../widgets/my_drawer.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:skill_share/utils/constants.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/video_widget.dart';


class EditProfile extends StatefulWidget {
  final Map<String, dynamic> user;
  final String uid;
  final List<String> userSkills;
  final List<String> userInterests;
  final Map<String, List<String>> media;
  const EditProfile({Key? key, required this.uid, required this.user, required this.userSkills, required this.userInterests, required this.media}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  int currentIndex = 0;
  late List<String> _allMedia;
  final ImagePicker picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  User? updateUser = FirebaseAuth.instance.currentUser;
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _country = TextEditingController();
  TextEditingController _zip = TextEditingController();
  TextEditingController _dob = TextEditingController(text: "");
  TextEditingController _bio = TextEditingController(text: "");
  late VideoPlayerController _controller;
  late String _profileUrl, _coverUrl;

  String _gender = "Male";
  var items = [
    'Male',
    'Female',
    'Other'
  ];

  bool loading = false;
  CroppedFile? _croppedProfile;
  CroppedFile? _croppedCover;
  late File _video;
  DateTime selectedDate = DateTime.now();
  List<String> chosenSkills = [];
  String selectedSkills = "";
  List<String> chosenInterests = [];
  String selectedInterest = "";
  ScrollController _scroll = ScrollController();


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(DateTime.now().year - 60),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dob.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _cropImage(pickedFile, type) async {
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Edit Image',
              toolbarColor: kPrimaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
            const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        if (type == "profile") {
          setState(() {
            _croppedProfile = croppedFile;
          });
        } else {
          setState(() {
            _croppedCover = croppedFile;
          });
        }
      }
    }
  }

  Future<void> _cropImageAndUpload(pickedFile) async {
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Upload Media',
              toolbarColor: kPrimaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
            const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      showLoadingDialog(context);
      Reference storageReference = storage.ref().child('media_images/${DateTime.now().millisecondsSinceEpoch}.png');
      UploadTask uploadTask = storageReference.putFile(File(croppedFile!.path));
      await uploadTask.then((TaskSnapshot taskSnapshot) async {
        String downloadUrl = await storageReference.getDownloadURL();
        setState(() {
          widget.media['images']!.add(downloadUrl);
          _allMedia.add(downloadUrl);
        });
      }).catchError((error) {
        // Handle errors when uploading the profile photo
      });
      Navigator.pop(context);
    }
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

  showVideoDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _controller.value.isInitialized
                        ? VideoPlayer(_controller)
                        : Container(),
                  ),
                  Positioned(
                    top: 10.0,
                    left: 10.0,
                    child: TextButton(
                      child: const Text("Tap to Play/Pause"),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            setState(() {
                              _controller.pause();
                            });
                          } else {
                            setState(() {
                              _controller.play();
                            });
                          }
                        });
                      },
                    ),
                  ),
                  Positioned(
                    top: 5.0,
                    right: 5.0,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red,),
                      onPressed: () {
                        _controller.pause();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 10.0,
                    right: 10.0,
                    child: ElevatedButton(
                      child: const Text("Add"),
                      onPressed: () async {
                        _controller.pause();
                        showLoadingDialog(context);
                        Reference storageReference = storage.ref().child('media_videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
                        UploadTask uploadTask = storageReference.putFile(_video);
                        await uploadTask.then((TaskSnapshot taskSnapshot) async {
                          String downloadUrl = await storageReference.getDownloadURL();
                          setState(() {
                            widget.media['videos']!.add(downloadUrl);
                            _allMedia.add(downloadUrl);
                          });
                        }).catchError((error) {
                          // Handle errors when uploading the profile photo
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  void pickVideo() async {
    showLoadingDialog(context);
    FilePickerResult? video = await FilePicker.platform.pickFiles(type: FileType.video, allowCompression: false);
    if (video!= null) {
      File file = File(video.files.single.path!);
      _controller = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {
            _video = file;
            Navigator.pop(context);
            showVideoDialog(context);
          });
        });

    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _gender = widget.user['gender'];
      _firstName.text = widget.user['first_name'];
      _lastName.text = widget.user['last_name'];
      _phone.text = widget.user['phone'];
      _address.text = widget.user['address'];
      _city.text = widget.user['city'];
      _state.text = widget.user['state'];
      _country.text = widget.user['country'];
      _zip.text = widget.user['zip'];
      _dob.text = widget.user['dob'];
      _bio.text = widget.user['bio'];
      selectedDate = DateTime.parse(widget.user['dob']);
      chosenSkills = widget.userSkills;
      chosenInterests = widget.userInterests;
      final allItems = [...widget.media['images']!, ...widget.media['videos']!];
      final random = Random();
      allItems.shuffle(random);
      _allMedia = allItems;
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
          TextButton(
            onPressed: () async {
              if(_formKey.currentState!.validate()) {
                showLoadingDialog(context);
                _formKey.currentState!.save();
                if (_croppedProfile!= null)
                {
                  Reference storageReference = storage.ref().child('profile_photos/${DateTime.now().millisecondsSinceEpoch}.png');
                  UploadTask uploadTask = storageReference.putFile(File(_croppedProfile!.path));
                  await uploadTask.then((TaskSnapshot taskSnapshot) async {
                    String downloadUrl = await storageReference.getDownloadURL();
                    setState(() {
                      _profileUrl = downloadUrl;
                    });
                  }).catchError((error) {
                    // Handle errors when uploading the profile photo
                  });
                }
                else
                  {
                    setState(() {
                      _profileUrl = widget.user['profile_url'];
                    });
                  }
                if (_croppedCover!= null)
                {
                  Reference storageReference1 = storage.ref().child('cover_photos/${DateTime.now().millisecondsSinceEpoch}.png');
                  UploadTask uploadTask = storageReference1.putFile(File(_croppedCover!.path));
                  await uploadTask.then((TaskSnapshot taskSnapshot) async {
                    String downloadUrl = await storageReference1.getDownloadURL();
                    setState(() {
                      _coverUrl = downloadUrl;
                    });
                  }).catchError((error) {
                    // Handle errors when uploading the profile photo
                  });
                }
                else{
                  setState(() {
                    _coverUrl = widget.user['cover_url'];
                  });
                }
                DocumentReference documentReference = firestore.collection('users').doc(widget.uid);
                await documentReference.set({
                  'first_name': _firstName.text,
                  'last_name': _lastName.text,
                  'phone': _phone.text,
                  'address': _address.text,
                  'dob': _dob.text,
                  'profile_url': _profileUrl,
                  'cover_url': _coverUrl,
                  'gender': _gender,
                  'city': _city.text,
                  'country': _country.text,
                  'state': _state.text,
                  'zip': _zip.text,
                  'bio': _bio.text,
                  'email': MyUser.email
                }).then((value) {
                  setState(() {
                    MyUser.uid = widget.uid;
                    MyUser.firstName = _firstName.text;
                    MyUser.lastName = _lastName.text;
                    MyUser.address = _address.text;
                    MyUser.dob = _dob.text;
                    MyUser.phone = _phone.text;
                    MyUser.profileUrl = _profileUrl;
                    MyUser.coverUrl = _coverUrl;
                    MyUser.gender = _gender;
                    MyUser.city = _city.text;
                    MyUser.country = _country.text;
                    MyUser.state = _state.text;
                    MyUser.zip = _zip.text;
                    MyUser.email = MyUser.email;
                    MyUser.bio = _bio.text;
                  });
                  // Profile data was successfully uploaded
                }).catchError((error) {
                  // Handle errors when uploading profile data
                });
                if(chosenSkills.isNotEmpty)
                {
                  DocumentReference documentReference = firestore.collection('skills').doc(widget.uid);
                  await documentReference.set({
                    'my_skills': chosenSkills,
                  }).then((value) {
                  }).catchError((error) {
                  });
                }
                if(chosenInterests.isNotEmpty)
                {
                  DocumentReference documentReference = firestore.collection('interests').doc(widget.uid);
                  await documentReference.set({
                    'my_interests': chosenInterests,
                  }).then((value) {
                  }).catchError((error) {
                  });
                }
                DocumentReference documentReference1 = firestore.collection('multimedia').doc(widget.uid);
                await documentReference1.set({
                  'images': widget.media['images'],
                  'videos': widget.media['videos'],
                }).then((value) {
                }).catchError((error) {
                });
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProfile(uid: widget.uid),
                  ),
                );
              }
            },
            child: Text("Save", style: textButton,),
          )
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
              Text("Edit Profile", style: titleText,),
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
                            GestureDetector(
                              onTap: (){
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.image, color: kPrimaryColor,),
                                          title: const Text('Gallery',),
                                          onTap: () async {
                                            final profile = await picker.pickImage(source: ImageSource.gallery);
                                            if (profile != null)
                                            {
                                              _cropImage(profile, 'cover');
                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera, color: kPrimaryColor,),
                                          title: const Text('Camera'),
                                          onTap: () async {
                                            final profile = await picker.pickImage(source: ImageSource.camera);
                                            if (profile != null)
                                            {
                                              _cropImage(profile, 'cover');
                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
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
                                      image: widget.user['cover_url']!= "" &&  _croppedCover == null ? NetworkImage(widget.user['cover_url']) : _croppedCover!=null && widget.user['cover_url']== "" ? FileImage(File(_croppedCover!.path)) : _croppedCover!=null && widget.user['cover_url']!= "" ? FileImage(File(_croppedCover!.path)) : const AssetImage("images/dummy_cover.jpeg") as ImageProvider,
                                    )
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 80),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: TextFormField(
                                            controller: _bio,
                                            readOnly: loading,
                                            obscureText: false,
                                            validator: (String? value) =>
                                            value!.isEmpty ? 'Bio is required' : null,
                                            keyboardType: TextInputType.name,
                                            decoration: const InputDecoration(
                                              labelText: "Bio",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: TextFormField(
                                            controller: _firstName,
                                            readOnly: loading,
                                            obscureText: false,
                                            validator: (String? value) =>
                                            value!.isEmpty ? 'First name is required' : null,
                                            keyboardType: TextInputType.name,
                                            decoration: const InputDecoration(
                                              labelText: "First Name",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: TextFormField(
                                            controller: _lastName,
                                            readOnly: loading,
                                            obscureText: false,
                                            validator: (String? value) =>
                                            value!.isEmpty ? 'Last name is required' : null,
                                            keyboardType: TextInputType.name,
                                            decoration: const InputDecoration(
                                              labelText: "Last Name",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: TextFormField(
                                          controller: _dob,
                                          validator: (String? value) =>
                                          value!.isEmpty ? 'Date of Birth is required' : null,
                                          onTap: (){
                                            _selectDate(context);
                                          },
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            labelText: "Date of Birth",
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: kPrimaryColor),
                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: DropdownButton(
                                          value: _gender,
                                          isExpanded: true,
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          items: items.map((String items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _gender = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: TextFormField(
                                            controller: _phone,
                                            readOnly: loading,
                                            obscureText: false,
                                            validator: (String? value) =>
                                            value!.isEmpty ? 'Phone is required' : null,
                                            keyboardType: TextInputType.phone,
                                            decoration: const InputDecoration(
                                              labelText: "Phone",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: TextFormField(
                                            controller: _address,
                                            readOnly: loading,
                                            obscureText: false,
                                            validator: (String? value) =>
                                            value!.isEmpty ? 'Address is required' : null,
                                            keyboardType: TextInputType.streetAddress,
                                            decoration: const InputDecoration(
                                              labelText: "Address",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: TextFormField(
                                            controller: _city,
                                            readOnly: loading,
                                            obscureText: false,
                                            validator: (String? value) =>
                                            value!.isEmpty ? 'City is required' : null,
                                            keyboardType: TextInputType.text,
                                            decoration: const InputDecoration(
                                              labelText: "City",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: TextFormField(
                                            controller: _state,
                                            readOnly: loading,
                                            obscureText: false,
                                            validator: (String? value) =>
                                            value!.isEmpty ? 'State is required' : null,
                                            keyboardType: TextInputType.text,
                                            decoration: const InputDecoration(
                                              labelText: "State",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: TextFormField(
                                            controller: _country,
                                            readOnly: loading,
                                            obscureText: false,
                                            validator: (String? value) =>
                                            value!.isEmpty ? 'Country is required' : null,
                                            keyboardType: TextInputType.text,
                                            decoration: const InputDecoration(
                                              labelText: "Country",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: TextFormField(
                                            controller: _zip,
                                            readOnly: loading,
                                            obscureText: false,
                                            validator: (String? value) =>
                                            value!.isEmpty ? 'Zip Code is required' : null,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: "Zip Code",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                )
                            )
                          ],
                        ),
                        Positioned(
                          top: 120.0, // (background container size) - (circle height / 2)
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 3),
                                shape: BoxShape.circle
                            ),
                            child: CircleAvatar(
                              backgroundImage: widget.user['profile_url']!= "" && _croppedProfile == null ? NetworkImage(widget.user['profile_url']) : _croppedProfile!=null && widget.user['profile_url']== "" ? FileImage(File(_croppedProfile!.path)) : _croppedProfile!=null && widget.user['profile_url']!= "" ? FileImage(File(_croppedProfile!.path)) : const AssetImage("images/dummy_user.png") as ImageProvider,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Wrap(
                                            children: [
                                              ListTile(
                                                leading: const Icon(Icons.image, color: kPrimaryColor,),
                                                title: const Text('Gallery',),
                                                onTap: () async {
                                                  final profile = await picker.pickImage(source: ImageSource.gallery);
                                                  if (profile != null)
                                                  {
                                                    _cropImage(profile, 'profile');
                                                    Navigator.pop(context);
                                                  }
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.camera, color: kPrimaryColor,),
                                                title: const Text('Camera'),
                                                onTap: () async {
                                                  final profile = await picker.pickImage(source: ImageSource.camera);
                                                  if (profile != null)
                                                  {
                                                    _cropImage(profile, 'profile');
                                                    Navigator.pop(context);
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text("Select the top 10 skills that best describe your strengths and expertise.", style: subTitle,),
                        const SizedBox(height: 20,),
                        DropdownSearch<String>.multiSelection(
                          mode: Mode.MENU,
                          showSelectedItems: true,
                          showClearButton: true,
                          showSearchBox: true,
                          items: skills,
                          selectedItems: chosenSkills,
                          dropdownSearchDecoration: const InputDecoration(
                            labelText: "Choose Skills",
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
                                chosenSkills = value;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 30,),
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
                            labelText: "Choose Skills",
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
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: MasonryGridView.builder(
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _allMedia.length,
                        itemBuilder: (context, index) {
                          final item = _allMedia[index];
                          return Stack(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                                  child: item.contains('.mp4')
                                      ? VideoWidget(url: item)
                                      : FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: item,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: const Icon(Icons.close, color: kPrimaryColor, size: 20, weight: 20,),
                                      onPressed: () {
                                        if (item.contains('.mp4')){
                                          widget.media["videos"]?.remove(item);
                                        }else{
                                          widget.media["images"]?.remove(item);
                                        }
                                        setState(() {
                                          final allItems = [...widget.media['images']!, ...widget.media['videos']!];
                                          final random = Random();
                                          allItems.shuffle(random);
                                          _allMedia = allItems;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }, gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: currentIndex == 2 ? FloatingActionButton(
        backgroundColor: kPrimaryColor,
        tooltip: "Create Post",
        child: Icon(Icons.add, size: 30,),
        onPressed: (){
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.image, color: kPrimaryColor,),
                    title: const Text('Image',),
                    onTap: () async {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.image, color: kPrimaryColor,),
                                title: const Text('Gallery',),
                                onTap: () async {
                                  final file = await picker.pickImage(source: ImageSource.gallery);
                                  if (file != null)
                                  {
                                    _cropImageAndUpload(file);

                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera, color: kPrimaryColor,),
                                title: const Text('Camera'),
                                onTap: () async {
                                  final file = await picker.pickImage(source: ImageSource.camera);
                                  if (file != null)
                                  {
                                    _cropImageAndUpload(file);
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.video_file, color: kPrimaryColor,),
                    title: const Text('Video'),
                    onTap: () async {
                      pickVideo();
                    },
                  ),
                ],
              );
            },
          );
        },
      ) : SizedBox(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: kPrimaryColor,),
            label: "Profile",
            activeIcon: Icon(Icons.account_circle_outlined, color: kSelectedColor,),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined, color: kPrimaryColor,),
            label: "Skills",
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
}
