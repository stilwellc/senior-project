import 'package:flutter/material.dart';
import 'package:ruroomates/first_screen.dart';
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ruroomates/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.teal[700],
                    Colors.teal[200],
                  ]
              )
          ),
        ),
        title: new Text(
          'Edit Profile',
        ),
        centerTitle: true,
      ),
      body: new SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController controllerNickname;
  TextEditingController controllerAboutMe;
  TextEditingController controllerSnapchat;
  TextEditingController controllerInstagram;
  TextEditingController controllerTwitter;

  SharedPreferences prefs;

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  String snapchat = '';
  String instagram = '';
  String twitter = '';

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();
  final FocusNode focusNodeSnapchat = new FocusNode();
  final FocusNode focusNodeInstagram = new FocusNode();
  final FocusNode focusNodeTwitter = new FocusNode();


  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';
    snapchat = prefs.getString('snapchat') ?? '';
    instagram = prefs.getString('instagram') ?? '';
    twitter = prefs.getString('twitter') ?? '';


    controllerNickname = new TextEditingController(text: nickname);
    controllerAboutMe = new TextEditingController(text: aboutMe);
    controllerSnapchat = new TextEditingController(text: snapchat);
    controllerInstagram = new TextEditingController(text: instagram);
    controllerTwitter = new TextEditingController(text: twitter);


    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = id;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(id)
              .updateData({'nickname': nickname, 'aboutMe': aboutMe, 'photoUrl': photoUrl, 'snapchat': snapchat,
            'instagram' : instagram, 'twitter' : twitter}).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();
    focusNodeSnapchat.unfocus();
    focusNodeInstagram.unfocus();
    focusNodeTwitter.unfocus();

    setState(() {
      isLoading = true;
    });

    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'nickname': nickname, 'aboutMe': aboutMe, 'photoUrl': photoUrl, 'snapchat': snapchat,
      'instagram': instagram, 'twitter': twitter}).then((data) async {
      await prefs.setString('nickname', nickname);
      await prefs.setString('aboutMe', aboutMe);
      await prefs.setString('photoUrl', photoUrl);
      await prefs.setString('snapchat', snapchat);
      await prefs.setString('instagram', instagram);
      await prefs.setString('twitter', twitter);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Avatar
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (avatarImageFile == null)
                          ? (photoUrl != ''
                          ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                            width: 90.0,
                            height: 90.0,
                            padding: EdgeInsets.all(20.0),
                          ),
                          imageUrl: photoUrl,
                          width: 90.0,
                          height: 90.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(45.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                          : Icon(
                        Icons.account_circle,
                        size: 90.0,
                        color: greyColor,
                      ))
                          : Material(
                        child: Image.file(
                          avatarImageFile,
                          width: 90.0,
                          height: 90.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(45.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: primaryColor.withOpacity(0.5),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(30.0),
                        splashColor: Colors.transparent,
                        highlightColor: greyColor,
                        iconSize: 30.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),

              // Input
              Column(
                children: <Widget>[
                  // Username
                  Container(
                    child: Text(
                      'Nickname',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Sweetie',
                          contentPadding: new EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerNickname,
                        onChanged: (value) {
                          nickname = value;
                        },
                        focusNode: focusNodeNickname,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  // About me
                  Container(
                    child: Text(
                      'About me',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Fun, like travel and play PES...',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerAboutMe,
                        onChanged: (value) {
                          aboutMe = value;
                        },
                        focusNode: focusNodeAboutMe,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  // Snapchat account
                  Container(
                    child: Text(
                      'Snapchat Username',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'JohnDoe123',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerSnapchat,
                        onChanged: (value) {
                          snapchat = value;
                        },
                        focusNode: focusNodeSnapchat,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  // Instagram
                  Container(
                    child: Text(
                      'Instagram Username',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'JohnD',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerInstagram,
                        onChanged: (value) {
                          instagram = value;
                        },
                        focusNode: focusNodeInstagram,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  // Twitter Account
                  Container(
                    child: Text(
                      'Twitter Username',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Johnny_Doe',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerTwitter,
                        onChanged: (value) {
                          twitter = value;
                        },
                        focusNode: focusNodeTwitter,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Button
              Container(
                child: FlatButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    'Update',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Colors.teal,
                  highlightColor: new Color(0xff8d93a0),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),

        // Loading
        Positioned(
          child: isLoading
              ? Container(
            child: Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
            ),
            color: Colors.white.withOpacity(0.8),
          )
              : Container(),
        ),
      ],
    );
  }
}
