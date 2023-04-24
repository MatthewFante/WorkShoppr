// Matthew Fante
// INFO-C342: Mobile Application Development
// Spring 2023 Final Project

// this class describes a reservation object and contains methods for creating and reading reservations from the database

import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String equipmentReserved;
  final String date;
  final String timeSlot;
  final String notes;
  final String userId;

  Reservation({
    required this.equipmentReserved,
    required this.date,
    required this.timeSlot,
    required this.notes,
    required this.userId,
  });

  // convert a reservation object to a json object
  Map<String, dynamic> toJson() => {
        'equipmentReserved': equipmentReserved,
        'date': date,
        'timeSlot': timeSlot,
        'notes': notes,
      };

  // create a Reservation object from a json object
  static Reservation fromJson(Map<String, dynamic> json) => Reservation(
        equipmentReserved: json['equipmentReserved'],
        date: json['date'],
        timeSlot: json['timeSlot'],
        notes: json['notes'],
        userId: json['userId'],
      );

  // read all reservations from the database
  static Stream<List<Reservation>> readReservations() =>
      FirebaseFirestore.instance.collection('reservations').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Reservation.fromJson(doc.data()))
              .toList());

  // create a new reservation in the database
  static Future<void> createReservation({
    required String equipmentReserved,
    required String date,
    required String timeSlot,
    required String notes,
    required String userId,
  }) async {
    final docReservation =
        FirebaseFirestore.instance.collection('reservations').doc();
    final reservationObj = Reservation(
      equipmentReserved: equipmentReserved,
      date: date,
      timeSlot: timeSlot,
      notes: notes,
      userId: userId,
    );
    var json = reservationObj.toJson();
    await docReservation.set(json);
  }

  factory Reservation.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Reservation(
      userId: data['userId'],
      equipmentReserved: data['equipmentReserved'],
      date: data['date'],
      timeSlot: data['timeSlot'],
      notes: data['notes'],
    );
  }
}
