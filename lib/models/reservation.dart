import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String equipmentReserved;
  final DateTime date;
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

  Map<String, dynamic> toJson() => {
        'equipmentReserved': equipmentReserved,
        'date': date.toIso8601String(),
        'timeSlot': timeSlot,
        'notes': notes,
      };

  static Reservation fromJson(Map<String, dynamic> json) => Reservation(
        equipmentReserved: json['equipmentReserved'],
        date: DateTime.parse(json['date']),
        timeSlot: json['timeSlot'],
        notes: json['notes'],
        userId: json['userId'],
      );

  static Stream<List<Reservation>> readReservations(DateTime date) =>
      FirebaseFirestore.instance
          .collection('reservations')
          .where('date', isEqualTo: date.toIso8601String())
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Reservation.fromJson(doc.data()))
              .toList());

  static Future<void> createReservation({
    required String equipmentReserved,
    required DateTime date,
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
      date: (data['date'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'],
      notes: data['notes'],
    );
  }
}
