import 'package:cloud_firestore/cloud_firestore.dart';

class RSVP {
  final String uid;
  final String classId;

  RSVP({required this.uid, required this.classId});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'classId': classId,
      };

  static RSVP fromJson(Map<String, dynamic> json) =>
      RSVP(uid: json['uid'], classId: json['classId']);

  static Stream<List<RSVP>> readRSVPs(String classId) =>
      FirebaseFirestore.instance
          .collection('rsvps')
          .where('classId', isEqualTo: classId)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => RSVP.fromJson(doc.data())).toList());

  static Future createRSVP(
      {required String uid, required String classId}) async {
    final docRSVP = FirebaseFirestore.instance.collection('rsvps').doc();
    final rsvpObj = RSVP(uid: uid, classId: classId);
    var json = rsvpObj.toJson();
    await docRSVP.set(json);
  }
}
