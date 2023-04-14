import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewClassDialog extends StatefulWidget {
  const NewClassDialog({
    super.key,
  });

  @override
  _NewClassDialogState createState() => _NewClassDialogState();
}

class _NewClassDialogState extends State<NewClassDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _attendeeCapacityController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    User? getCurrentUser() {
      final User? user = FirebaseAuth.instance.currentUser;
      return user;
    }

    final username = getCurrentUser()?.displayName ?? 'Unknown';
    return AlertDialog(
      title: const Text('New Class'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dateTimeController.text != ''
                        ? formatDateTime(_dateTimeController.text)
                        : 'Date & Time',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      // Open the CupertinoDatePicker.
                      showModalBottomSheet(
                        isDismissible: true,
                        context: context,
                        builder: (BuildContext builder) {
                          return SizedBox(
                            height: 250.0,
                            child: CupertinoDatePicker(
                              // minuteInterval: 15,
                              initialDateTime: getNoonTomorrow(),
                              minuteInterval: 30,
                              onDateTimeChanged: (DateTime date) {
                                // Set the text field to the selected date.
                                _dateTimeController.text = date.toString();
                                setState(() {});
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (min)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: _attendeeCapacityController,
                      decoration: const InputDecoration(
                        labelText: 'Capacity',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Get the values from the text fields
              String title = _titleController.text;
              String description = _descriptionController.text;
              String dateTime = _dateTimeController.text;
              int duration = int.parse(_durationController.text);
              int attendeeCapacity =
                  int.parse(_attendeeCapacityController.text);

              // Create a new class document
              DocumentReference classRef =
                  FirebaseFirestore.instance.collection('classes').doc();
              classRef.set({
                'id': classRef.id,
                'userName': username,
                'title': title,
                'description': description,
                'dateTime': dateTime,
                'duration': duration,
                'attendeeCapacity': attendeeCapacity,
                'attendeesRegistered': 0,
              });

              // Dismiss the dialog
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

String formatDateTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  DateFormat formatter = DateFormat('MMMM d, y, h:mm a');
  String prettyDateTime = formatter.format(dateTime);
  return prettyDateTime;
}

DateTime getNoonTomorrow() {
  DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
  DateTime tomorrowAtNoon =
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0);

  return tomorrowAtNoon;
}
