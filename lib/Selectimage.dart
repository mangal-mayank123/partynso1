import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partynso/Homepage.dart';
import 'package:partynso/User.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  BuildContext context;
  ProgressDialog progressDialog;
  List<File> l = new List<File>(6);

  String image_path;
  File images, sample, sample0, sample1, sample2, sample3, sample4, sample5;
  var count = 0;
  Future getimage(int i) async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
      if (mounted) {
        if (value != null) {
          setState(() {
            image_path = value.path.split('/').last;
            l[i] = value;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    return Scaffold(
        appBar: AppBar(
          title: Text('Image Upload'),
          centerTitle: true,
        ),
        body: Column(children: <Widget>[
          GridView.count(
            shrinkWrap: true,
            crossAxisSpacing: 2,
            crossAxisCount: 3,
            children: <Widget>[
              InkWell(
                onTap: () {
                  getimage(0);
                  setState(() {});
                },
                child: l[0] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : Image.file(l[0]),
              ),
              InkWell(
                onTap: () {
                  getimage(1);
                  setState(() {});
                },
                child: l[1] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : Image.file(l[1]),
              ),
              InkWell(
                onTap: () {
                  getimage(2);
                  setState(() {});
                },
                child: l[2] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : Image.file(l[2]),
              ),
              InkWell(
                onTap: () {
                  getimage(3);
                  setState(() {});
                },
                child: l[3] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : Image.file(l[3]),
              ),
              InkWell(
                onTap: () {
                  getimage(4);
                },
                child: l[4] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : Image.file(l[4]),
              ),
              InkWell(
                onTap: () {
                  getimage(5);
                },
                child: l[5] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : Image.file(l[5]),
              ),
            ],
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: OutlineButton(
              onPressed: () async {
                progressDialog.show();
                await uploadToFirebase();
              },
              child: new Text("Next"),
            ),
          ),
        ]));
  }

  uploadToFirebase() async {
    int c = 0;
    l.forEach((filePath) {
      upload(filePath);
      c++;
    });
    if (c == l.length) {
      move();
    }
  }

  upload(filePath) async {
    print(l);
    StorageReference storageRef = FirebaseStorage.instance
        .ref()
        .child(filePath.toString().split("/").last);
    try {
      final StorageUploadTask uploadTask = await storageRef.putFile(
        filePath,
      );
      await uploadTask.onComplete;
      var dowurl = await storageRef.getDownloadURL();
      String url = dowurl.toString();
      Firestore.instance
          .collection('Profile')
          .document(User.userprofile['user_id'])
          .collection('images')
          .add({'url': url});
    } catch (e) {
      print(e);
    }
    progressDialog.hide();
  }

  void move() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Homepage()));
  }
}
