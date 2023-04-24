// Matthew Fante
// INFO-C342: Mobile Application Development
// Spring 2023 Final Project

// this class describes an rsvp object and contains methods for creating and reading rsvps from the database

import 'package:cloud_firestore/cloud_firestore.dart';

class RSVP {
  final String uid;
  final String classId;

  RSVP({required this.uid, required this.classId});

  // convert an rsvp object to a json object
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'classId': classId,
      };

  // create an RSVP object from a json object
  static RSVP fromJson(Map<String, dynamic> json) =>
      RSVP(uid: json['uid'], classId: json['classId']);

  // read all rsvps from the database for a given class id
  static Stream<List<RSVP>> readRSVPs(String classId) =>
      FirebaseFirestore.instance
          .collection('rsvps')
          .where('classId', isEqualTo: classId)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => RSVP.fromJson(doc.data())).toList());

  // create a new rsvp in the database
  static Future createRSVP(
      {required String uid, required String classId}) async {
    final docRSVP = FirebaseFirestore.instance.collection('rsvps').doc();
    final rsvpObj = RSVP(uid: uid, classId: classId);
    var json = rsvpObj.toJson();
    await docRSVP.set(json);
  }
}
