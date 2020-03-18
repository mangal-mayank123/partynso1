import 'dart:ffi';

class User {
  static bool isloggedin = false, isregisterd = false;
  static Map<String, dynamic> userprofile = {
    'f_name': '',
    'l_name': '',
    'dob': null,
    'relationship': null,
    'home': null,
    'mobno': null,
    'gender': null,
    'location': null,
    'email': null,
    'haspet': false,
    'drink': null,
    'smoking': null,
    'weed': null,
    'user_id': null,
    'profile_id': null,
    'img_url': null,
    'status': null,
    'college': null,
    'networking': null,
    'dating': null,
    'socialcircle': null,
    'password': null,
    'rating': 1,
    'no_of_ratings': 1,
  };
}
