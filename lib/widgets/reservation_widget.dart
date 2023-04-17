import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationWidget extends StatefulWidget {
  final String userId;
  final String equipmentReserved;
  final String date;
  final String timeSlot;
  final String notes;

  const ReservationWidget({
    Key? key,
    required this.userId,
    required this.equipmentReserved,
    required this.date,
    required this.timeSlot,
    required this.notes,
  }) : super(key: key);

  @override
  _ReservationWidgetState createState() => _ReservationWidgetState();
}

// Split the string into day, month, and year components

class _ReservationWidgetState extends State<ReservationWidget> {
  @override
  Widget build(BuildContext context) {
    List<String> dateComponents = widget.date.split('/');
    int day = int.parse(dateComponents[1]);
    int month = int.parse(dateComponents[0]);
    int year = int.parse(dateComponents[2]);
    DateTime dateTime = DateTime(year, month, day);

    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                DateFormat('MMMM')
                    .format(DateTime.parse(dateTime.toString()))
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              Text(
                DateFormat('d')
                    .format(DateTime.parse(dateTime.toString()))
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 64.0,
                ),
              ),
              Text(
                widget.timeSlot,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.equipmentReserved,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  widget.notes != '' ? 'Notes: ${widget.notes}' : 'No notes',
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                )
              ],
            ),
          ),
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 242, 174, 174)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('reservations')
                  .where('userId', isEqualTo: widget.userId)
                  .where('equipmentReserved',
                      isEqualTo: widget.equipmentReserved)
                  .where('date', isEqualTo: widget.date)
                  .where('timeSlot', isEqualTo: widget.timeSlot)
                  .get()
                  .then((querySnapshot) {
                for (var doc in querySnapshot.docs) {
                  doc.reference.delete();
                }
              });
            },
            child: const Text(
              'CANCEL',
              style: TextStyle(
                fontSize: 18.0,
                color: Color(0xff990000),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
