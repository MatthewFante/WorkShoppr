// Matthew Fante
// INFO-C342: Mobile Application Development
// Spring 2023 Final Project

// this class describes a class object and contains methods for creating and reading classes from the database

import 'package:cloud_firestore/cloud_firestore.dart';

class Class {
  final String id;
  final String userName;
  final String title;
  final String description;
  final String dateTime;
  final int duration;
  final int attendeeCapacity;
  final int attendeesRegistered;

  Class(
      {required this.id,
      required this.userName,
      required this.title,
      required this.description,
      required this.dateTime,
      required this.duration,
      required this.attendeeCapacity,
      required this.attendeesRegistered});

  // convert a class object to a json object
  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'title': title,
        'description': description,
        'dateTime': dateTime,
        'duration': duration,
        'attendeeCapacity': attendeeCapacity,
        'attendeesRegistered': attendeesRegistered,
      };

  // create a Class object from a json object
  static Class fromJson(Map<String, dynamic> json) => Class(
        id: json['id'],
        userName: json['userName'],
        title: json['title'],
        description: json['description'],
        dateTime: json['dateTime'],
        duration: json['duration'],
        attendeeCapacity: json['attendeeCapacity'],
        attendeesRegistered: json['attendeesRegistered'],
      );

  // read all classes from the database
  static Stream<List<Class>> readClasses() => FirebaseFirestore.instance
      .collection('classes')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Class.fromJson(doc.data())).toList());

  // create a new class in the database
  static Future createClass(
      {required String id,
      required String userName,
      required String title,
      required String description,
      required String dateTime,
      required int duration,
      required int attendeeCapacity}) async {
    final docClass = FirebaseFirestore.instance.collection('classes').doc();
    final classObj = Class(
      id: id,
      userName: userName,
      title: title,
      description: description,
      dateTime: dateTime,
      duration: duration,
      attendeeCapacity: attendeeCapacity,
      attendeesRegistered: 0,
    );
    var json = classObj.toJson();
    await docClass.set(json);
  }
}
