import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClassesWidget extends StatefulWidget {
  final String userId;
  final String classId;
  final String userName;
  final String title;
  final String description;
  final String dateTime;
  final int attendeeCapacity;
  final int attendeesRegistered;

  const ClassesWidget({
    required this.userId,
    required this.classId,
    required this.userName,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.attendeeCapacity,
    required this.attendeesRegistered,
  });

  @override
  State<ClassesWidget> createState() => _ClassesWidgetState();
}

class _ClassesWidgetState extends State<ClassesWidget> {
  @override
  Widget build(BuildContext context) {
    int spotsLeft = widget.attendeeCapacity - widget.attendeesRegistered;
    bool rsvpMade = false;

    void _onRSVP() {
      DocumentReference rsvpRef =
          FirebaseFirestore.instance.collection('rsvps').doc();

      DocumentReference classRef =
          FirebaseFirestore.instance.collection('classes').doc(widget.classId);

      classRef.update({
        'attendeesRegistered': FieldValue.increment(1),
      });
      rsvpRef.set({
        'uid': widget.userId,
        'classId': widget.classId,
      }).then((_) {
        setState(() {
          rsvpMade = true;
        });
      });
    }

    void _onCancelRSVP() {
      FirebaseFirestore.instance
          .collection('rsvps')
          .where('uid', isEqualTo: widget.userId)
          .where('classId', isEqualTo: widget.classId)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
        DocumentReference classRef = FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.classId);

        classRef.update({
          'attendeesRegistered': FieldValue.increment(-1),
        }).then((_) {
          setState(() {
            rsvpMade = false;
          });
        });
      });
    }

    void _onFull() {
      // Do nothing
      setState(() {
        rsvpMade = false;
      });
    }

    Future<bool> hasRsvp() async {
      final snapshot = await FirebaseFirestore.instance
          .collection('rsvps')
          .where('uid', isEqualTo: widget.userId)
          .where('classId', isEqualTo: widget.classId)
          .get();
      return snapshot.docs.isNotEmpty || rsvpMade;
    }

    return Card(
      color: Color.fromARGB(255, 213, 213, 213),
      // elevation: 5,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Column(children: [
                Text(
                  DateFormat('MMMM')
                      .format(DateTime.parse(widget.dateTime))
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  DateFormat('d').format(DateTime.parse(widget.dateTime)),
                  style: const TextStyle(
                    fontSize: 64.0,
                  ),
                ),
                Text(
                  DateFormat('h:mm a').format(DateTime.parse(widget.dateTime)),
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ]),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title.truncatedTitle,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 80,
                  width: 250,
                  child: Text(
                    widget.description.truncatedDescription,
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        '$spotsLeft / ${widget.attendeeCapacity} spots left',
                      ),
                    ),
                    FutureBuilder<bool>(
                        future: hasRsvp(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!) {
                              return TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color.fromARGB(255, 242, 174, 174)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                ),
                                onPressed: _onCancelRSVP,
                                child: const Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Color(0xff990000),
                                  ),
                                ),
                              );
                              ;
                            } else {
                              return spotsLeft != 0
                                  ? TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color(0xff990000)),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                      ),
                                      onPressed: _onRSVP,
                                      child: const Text(
                                        '   RSVP   ',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromARGB(
                                                    255, 242, 174, 174)),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                      ),
                                      onPressed: _onFull,
                                      child: const Text(
                                        '   FULL   ',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Color(0xff990000),
                                        ),
                                      ),
                                    );
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String get truncatedTitle {
    if (length <= 20) {
      return this;
    } else {
      return substring(0, 15) + '...';
    }
  }

  String get truncatedDescription {
    if (length <= 200) {
      return this;
    } else {
      return '${substring(0, 195)}...';
    }
  }
}
