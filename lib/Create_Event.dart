import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'Homepage.dart';
import 'Post.dart';
import 'User.dart';
import ',msa,c.dart';

class createevent extends StatefulWidget {
  LatLng lastMapPosition;

  @override
  _createeventState createState() => _createeventState();
}

class _createeventState extends State<createevent> {
  GoogleMapController mapController;
  String searchAddr;
  DateTime buttonvalue = DateTime.now();
  DateTime _currentdate = new DateTime.now();
  TimeOfDay _currenttime = new TimeOfDay.now();
  String image_path;
  ProgressDialog progressDialog;
  List<File> l = new List<File>(6);
  File images, sample, sample0, sample1, sample2, sample3, sample4, sample5;
  var count = 0;
  var formkey = GlobalKey<FormState>();
  var select_gender = 0;
  var dateFormat;
  String name, venuid;
  String address = " ";
  String member;
  var location = "l";
  String total_member;

  @override
  void initState() {
    if (widget.lastMapPosition == null) {
      address = "Address";
    } else {
      Geocoder.local
          .findAddressesFromCoordinates(Coordinates(
              widget.lastMapPosition.latitude,
              widget.lastMapPosition.longitude))
          .then((value) {
        setState(() {
          location = value.first.addressLine + "\n";
        });
      });
    }
  }

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
  Widget build(BuildContext context) {
    progressDialog = new ProgressDialog(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          GridView.count(
            shrinkWrap: true,
            physics: ScrollPhysics(),
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
            child: Form(
              key: formkey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Event Name',
                      ),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter Event Name';
                        }
                      },
                      onChanged: (v) {
                        name = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['E_name'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: RaisedButton.icon(
                      icon: Icon(Icons.location_on),
                      label: Text("Add Location"),
                      onPressed: () async {
                        widget.lastMapPosition = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MapsDemo()));
                        if (widget.lastMapPosition == null) {
                          address = "Address";
                        } else {
                          Geocoder.local
                              .findAddressesFromCoordinates(Coordinates(
                                  widget.lastMapPosition.latitude,
                                  widget.lastMapPosition.longitude))
                              .then((value) {
                            setState(() {
                              location = value.first.addressLine + "\n";
                            });
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Text(location),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'House_No.',
                      ),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      initialValue: address == 'Address' ? "Address" : address,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter Address ';
                        }
                      },
                      onChanged: (v) {
                        address = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['location'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'No of Members',
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'No of Members';
                        }
                      },
                      onChanged: (v) {
                        member = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['m_size'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: ' Age Group',
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Total Size';
                        }
                      },
                      onChanged: (v) {
                        total_member = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['age_group'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Gender Type',
                      ),
                      value: select_gender,
                      validator: (v) {
                        if (v == null) {
                          return 'Select the Gender';
                        }
                      },
                      onChanged: (v) {
                        setState(() {
                          select_gender = v;
                        });
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['gender_type'] = select_gender == 0
                              ? 'Man'
                              : select_gender == 1 ? 'Women' : 'Both';
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Man'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Women'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text("Both"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'What is this event about? ',
                      ),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter valid event about ';
                        }
                      },
                      onChanged: (v) {
                        address = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['about'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'What will we do ? ',
                      ),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter valid  information ';
                        }
                      },
                      onChanged: (v) {
                        address = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['wedo'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'What will be my contribution? ',
                      ),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter valid  information ';
                        }
                      },
                      onChanged: (v) {
                        address = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['contribute'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: ListTile(
                      leading: InkWell(
                        child: Icon(
                          Icons.calendar_today,
                        ),
                        onTap: () {
                          _selectDate(context);
                        },
                      ),
                      subtitle: Text(
                        _currentdate.toLocal().toString(),
                        style: TextStyle(fontSize: 15),
                      ),
                      title: Text('Date'),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: ListTile(
                      leading: InkWell(
                        child: Icon(
                          Icons.access_time,
                        ),
                        onTap: () {
                          _selecttime(context);
                        },
                      ),
                      subtitle: Text(
                        _currenttime.toString(),
                        style: TextStyle(fontSize: 15),
                      ),
                      title: Text('Time'),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: OutlineButton(
                      child: Text("Create Party"),
                      onPressed: () {
                        progressDialog.show();
                        savetodatabase();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _currentdate,
        firstDate: DateTime(1960, 8),
        lastDate: DateTime(2050));
    if (picked != null && picked != _currentdate)
      setState(() {
        _currentdate = picked;
      });
  }
  /*Future<Null> _selectdate(BuildContext context) async {
    final DateTime _seldate = await showDatePicker(
        context: context,
        initialDate: _currentdate,
        firstDate: DateTime(2018),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return SingleChildScrollView(
            child: child,
          );
        });
    if (_seldate != null) {
      setState(() {
        _currentdate = _seldate;
      });
    }
  }*/

  Future<Null> _selecttime(BuildContext context) async {
    final TimeOfDay _seldate = await showTimePicker(
      context: context,
      initialTime: _currenttime,
    );
    if (_seldate != null) {
      setState(() {
        _currenttime = _seldate;
      });
    }
  }

  Future<void> savetodatabase() async {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      Post.post['list'] = new List();
      Post.post['date'] = _currentdate.day.toString() +
          (_currentdate.month.toString().length == 1
              ? "/0" + _currentdate.month.toString()
              : '/' + _currentdate.month.toString()) +
          "/" +
          _currentdate.year.toString();
      Post.post['time'] =
          _currenttime.hour.toString() + ":" + _currenttime.minute.toString();
      String id = User.userprofile['user_id'];
      Post.post['user_id'] = id;
      Post.post['coordi_la'] = widget.lastMapPosition.latitude.toString();
      Post.post['coordi_lo'] = widget.lastMapPosition.longitude.toString();
      print(Post.post['coordi_la']);
      var y = await Firestore.instance.collection('Profile').document(id).get();
      Post.post['user_name'] = y.data['f_name'] + " " + y.data['l_name'];
      var x = await Firestore.instance.collection('Venue').add(Post.post);
      venuid = x.documentID;

      Firestore.instance.collection("Profile").snapshots().listen((event) {
        event.documents.forEach((element) {
          Firestore.instance
              .collection("Profile")
              .document(element.documentID)
              .collection("events")
              .add({'venue_id': venuid}).then((value) => print('inserted'));
        });
      });

      Post.post['venue_id'] = venuid;
      await Firestore.instance
          .collection('Venue')
          .document(venuid)
          .updateData(Post.post);
      await Firestore.instance
          .collection('Profile')
          .document(id)
          .collection('venues')
          .add({"venu_id": venuid});
      uploadToFirebase();
    }
  }

  uploadToFirebase() async {
    l.forEach((filePath) {
      upload(filePath);
    });
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
          .collection('Venue')
          .document(venuid)
          .collection('images')
          .add({'url': url});
    } catch (e) {
      print(e);
    }
    progressDialog.hide();
  }
}
