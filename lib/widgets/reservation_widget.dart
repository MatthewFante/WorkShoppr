// Matthew Fante
// INFO-C342: Mobile Application Development
// Spring 2023 Final Project

// this widget is used to display a reservation in the reservations page

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
    // Split the string into day, month, and year components
    List<String> dateComponents = widget.date.split('/');
    int day = int.parse(dateComponents[1]);
    int month = int.parse(dateComponents[0]);
    int year = int.parse(dateComponents[2]);

    // Create a DateTime object
    DateTime dateTime = DateTime(year, month, day);

    // Return the reservation widget
    return Card(
        color: const Color.fromARGB(255, 213, 213, 213),
        // elevation: 5,
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
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
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.equipmentReserved.truncatedEquipment,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 50,
                      child: Text(
                        // If there are notes, display them
                        widget.notes != ''
                            ? 'Notes: ${widget.notes.truncatedNotes}'
                            : 'No notes',
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 200),
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
                            // Delete the reservation from the database
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 70,
              )
            ],
          ),
        ));
  }
}

extension on String {
  // Truncate the string if it is too long
  String get truncatedEquipment {
    if (length <= 20) {
      return this;
    } else {
      return '${substring(0, 18)}...';
    }
  }

  // Truncate the string if it is too long
  String get truncatedNotes {
    if (length <= 150) {
      return this;
    } else {
      return '${substring(0, 145)}...';
    }
  }
}
