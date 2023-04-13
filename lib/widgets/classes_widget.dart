import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClassesWidget extends StatelessWidget {
  final String userName;
  final String title;
  final String description;
  final String dateTime;
  final int attendeeCapacity;
  final int attendeesRegistered;

  const ClassesWidget({
    required this.userName,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.attendeeCapacity,
    required this.attendeesRegistered,
  });

  @override
  Widget build(BuildContext context) {
    int spotsLeft = attendeeCapacity - attendeesRegistered;
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
                      .format(DateTime.parse(dateTime))
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  DateFormat('d').format(DateTime.parse(dateTime)),
                  style: const TextStyle(
                    fontSize: 64.0,
                  ),
                ),
                Text(
                  DateFormat('h:mm a').format(DateTime.parse(dateTime)),
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
                  title.truncatedTitle,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 80,
                  width: 250,
                  child: Text(
                    description.truncatedDescription,
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        '$spotsLeft / $attendeeCapacity spots left',
                      ),
                    ),
                    spotsLeft != 0
                        ? TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xff990000)),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                            onPressed: () {},
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
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(255, 242, 174, 174)),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              '   FULL   ',
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
          ],
        ),
      ),
    );
  }
}

extension on String {
  String get truncatedTitle {
    if (this.length <= 20) {
      return this;
    } else {
      return this.substring(0, 15) + '...';
    }
  }

  String get truncatedDescription {
    if (this.length <= 200) {
      return this;
    } else {
      return this.substring(0, 195) + '...';
    }
  }
}
