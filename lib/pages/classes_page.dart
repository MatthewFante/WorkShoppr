import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workshoppr/models/class.dart';
import 'package:workshoppr/widgets/classes_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({
    super.key,
  });
  // final String title;

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  User? getCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<List<Class>>(
          stream: Class.readClasses(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final classes = snapshot.data!;
              classes.sort((a, b) => a.dateTime.compareTo(b.dateTime));

              var futureClasses = classes.where((classObj) =>
                  DateTime.parse(classObj.dateTime)
                      .isAfter(DateTime.now().toUtc()));

              return ListView.separated(
                itemBuilder: (context, index) =>
                    buildClass(futureClasses.toList()[index]),
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                  height: 1.0,
                ),
                itemCount: futureClasses.length,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  Widget buildClass(Class classObj) {
    int spotsLeft = classObj.attendeeCapacity - classObj.attendeesRegistered;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(classObj.title),
                          Text(formatDateTime(classObj.dateTime.toString()),
                              style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Hosted by: ${classObj.userName}'),
                    const SizedBox(height: 10),
                    Text(classObj.description),
                    const SizedBox(height: 10),
                    Text(
                        '$spotsLeft / ${classObj.attendeeCapacity} spots left'),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: ClassesWidget(
        userId: getCurrentUser()!.uid,
        classId: classObj.id,
        userName: classObj.userName,
        title: classObj.title,
        description: classObj.description,
        dateTime: classObj.dateTime.toString(),
        attendeeCapacity: classObj.attendeeCapacity,
        attendeesRegistered: classObj.attendeesRegistered,
      ),
    );
  }
}

String formatDateTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  DateFormat formatter = DateFormat('EEEE, MMMM d, y, h:mm a');
  String prettyDateTime = formatter.format(dateTime);
  return prettyDateTime;
}
