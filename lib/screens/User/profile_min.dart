import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:skill_share/models/static/user.dart';
import 'package:skill_share/screens/User/choose_interests.dart';
import 'package:skill_share/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:skill_share/utils/constants.dart';
import 'package:skill_share/widgets/loader.dart';


class UserProfileMin extends StatefulWidget {
  const UserProfileMin({Key? key}) : super(key: key);

  @override
  State<UserProfileMin> createState() => _UserProfileMinState();
}

class _UserProfileMinState extends State<UserProfileMin> {
  final ImagePicker picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String? _firstName, _lastName, _address, _phone, _dob, _profileUrl, _coverUrl,
           _city, _state, _zip, _country;
  String _gender = 'Male';
  var items = [
    'Male',
    'Female',
    'Other'
  ];

  bool loading = false;
  CroppedFile? _croppedProfile;
  CroppedFile? _croppedCover;
  DateTime selectedDate = DateTime.now();
  TextEditingController dob = TextEditingController(text: "");

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(DateTime.now().year - 60),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dob.text = "${selectedDate.toLocal()}".split(' ')[0];
        _dob = "${selectedDate.toLocal()}".split(' ')[0];
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
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
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




  @override
  Widget build(BuildContext context) {
    return loading ? Center(child: CircularProgressIndicator(color: Colors.white,)) : Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        actions: [
          TextButton(
            child: Text("Next", style: textButton,),
            onPressed: () async {
              if(_formKey.currentState!.validate()){
                _formKey.currentState!.save();
                showLoadingDialog(context);
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
                DocumentReference documentReference = firestore.collection('users').doc(user!.uid);
                await documentReference.set({
                  'first_name': _firstName,
                  'last_name': _lastName,
                  'phone': _phone,
                  'address': _address,
                  'dob': _dob,
                  'profile_url': _profileUrl,
                  'cover_url': _coverUrl,
                  'gender': _gender,
                  'city': _city,
                  'country': _country,
                  'state': _state,
                  'zip': _zip,
                  'email': user!.email,
                  'bio': ""
                }).then((value) {
                  MyUser.uid = user!.uid;
                  MyUser.firstName = _firstName!;
                  MyUser.lastName = _lastName!;
                  MyUser.address = _address!;
                  MyUser.dob = _dob!;
                  MyUser.phone = _phone!;
                  MyUser.profileUrl = _profileUrl!;
                  MyUser.coverUrl = _coverUrl!;
                  MyUser.gender = _gender!;
                  MyUser.city = _city!;
                  MyUser.country = _country!;
                  MyUser.state = _state!;
                  MyUser.zip = _zip!;
                  MyUser.email = user!.email!;
                  // Profile data was successfully uploaded
                }).catchError((error) {
                  // Handle errors when uploading profile data
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChooseInterests(),
                  ),
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Getting Started", style: titleText,),
              const SizedBox(
                height: 20,
              ),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
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
                                image: _croppedCover!= null ? FileImage(File(_croppedCover!.path)) : const AssetImage("images/dummy_cover.jpeg") as ImageProvider,
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
                                      readOnly: loading,
                                      obscureText: false,
                                      validator: (String? value) =>
                                      value!.isEmpty ? 'First name is required' : null,
                                      onSaved: (value) => setState(() {
                                        _firstName = value!;
                                      }),
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
                                      readOnly: loading,
                                      obscureText: false,
                                      validator: (String? value) =>
                                      value!.isEmpty ? 'Last name is required' : null,
                                      onSaved: (value) => setState(() {
                                        _lastName = value!;
                                      }),
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
                                    controller: dob,
                                    validator: (String? value) =>
                                    value!.isEmpty ? 'Date of Birth is required' : null,
                                    onSaved: (value) => setState(() {
                                      _phone = value!;
                                    }),
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
                                      readOnly: loading,
                                      obscureText: false,
                                      validator: (String? value) =>
                                      value!.isEmpty ? 'Phone is required' : null,
                                      onSaved: (value) => setState(() {
                                        _phone = value!;
                                      }),
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
                                      readOnly: loading,
                                      obscureText: false,
                                      validator: (String? value) =>
                                      value!.isEmpty ? 'Address is required' : null,
                                      onSaved: (value) => setState(() {
                                        _address = value!;
                                      }),
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
                                      readOnly: loading,
                                      obscureText: false,
                                      validator: (String? value) =>
                                      value!.isEmpty ? 'City is required' : null,
                                      onSaved: (value) => setState(() {
                                        _city = value!;
                                      }),
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
                                      readOnly: loading,
                                      obscureText: false,
                                      validator: (String? value) =>
                                      value!.isEmpty ? 'State is required' : null,
                                      onSaved: (value) => setState(() {
                                        _state = value!;
                                      }),
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
                                      readOnly: loading,
                                      obscureText: false,
                                      validator: (String? value) =>
                                      value!.isEmpty ? 'Country is required' : null,
                                      onSaved: (value) => setState(() {
                                        _country = value!;
                                      }),
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
                                      readOnly: loading,
                                      obscureText: false,
                                      validator: (String? value) =>
                                      value!.isEmpty ? 'Zip Code is required' : null,
                                      onSaved: (value) => setState(() {
                                        _zip = value!;
                                      }),
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
                  // Profile image
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
                        backgroundImage: _croppedProfile!= null ? FileImage(File(_croppedProfile!.path)) : const AssetImage("images/dummy_user.png") as ImageProvider,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
