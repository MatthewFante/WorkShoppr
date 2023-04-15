import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EquipmentPage extends StatefulWidget {
  @override
  _EquipmentPageState createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();
  var _selectedEquipment = '';
  var _selectedTimeSlot = '';

  List<String> _availableEquipment = [];
  List<String> _availableTimeSlots = [];

  Future<List<String>> getTimeslots() async {
    List<String> timeslots = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('timeslots').get();
    snapshot.docs.forEach((doc) {
      timeslots.add(doc['slot']);
    });
    return timeslots;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getTimeslots().then((timeslots) {
      setState(() {
        _availableTimeSlots = timeslots;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    User? getCurrentUser() {
      final User? user = FirebaseAuth.instance.currentUser;
      return user;
    }

    final currentUserName = getCurrentUser()?.displayName ?? 'Unknown';
    final currentUserId = getCurrentUser()?.uid ?? 'Unknown';
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance.collection('equipment').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  _availableEquipment = snapshot.data!.docs
                      .map((doc) => doc['name'].toString())
                      .toList();

                  _availableEquipment.sort((a, b) => a.compareTo(b));
                  _selectedEquipment = _availableEquipment[0];
                  return DropdownButtonFormField(
                    value: _selectedEquipment,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedEquipment = newValue as String;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Equipment Reserved',
                    ),
                    items: _availableEquipment.map((equipment) {
                      return DropdownMenuItem(
                        value: equipment,
                        child: Text(equipment),
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dateController.text != ''
                        ? formatDate(_dateController.text)
                        : 'Date',
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
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: DateTime.now(),
                              onDateTimeChanged: (DateTime date) {
                                // Set the text field to the selected date.
                                _dateController.text = date.toString();
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
              SizedBox(height: 16.0),
              FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance.collection('timeslots').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  _availableTimeSlots = snapshot.data!.docs
                      .map((doc) => doc['slot'].toString())
                      .toSet() // Remove duplicates
                      .toList();

                  _availableTimeSlots.sort((a, b) => a.compareTo(b));
                  _selectedTimeSlot = _availableTimeSlots[0];
                  return DropdownButtonFormField(
                    value: _selectedTimeSlot,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTimeSlot = newValue as String;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Time Slot',
                    ),
                    items: _availableTimeSlots.map((timeslot) {
                      return DropdownMenuItem(
                        value: timeslot,
                        child: Text(timeslot),
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                ),
                validator: (value) {
                  // Notes are optional, so no validation needed
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Create a new reservation document
                      await FirebaseFirestore.instance
                          .collection('reservations')
                          .add({
                        'userId': currentUserId,
                        'equipmentReserved': _selectedEquipment,
                        'date': formatDate(_dateController.text),
                        'timeSlot': _selectedTimeSlot,
                        'notes': _notesController.text,
                      });

                      // Show a snackbar with a message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reservation successful!')),
                      );
                    }

                    _dateController.text = '';
                    _selectedTimeSlot = _availableTimeSlots[0];
                    _notesController.text = '';
                    _selectedEquipment = '';
                    _selectedTimeSlot = '';
                  },
                  child: Text('Request Reservation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatDate(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  DateFormat formatter = DateFormat('MM/d/y');
  String prettyDateTime = formatter.format(dateTime);
  return prettyDateTime;
}

String? validateDate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please choose a date';
  }
  final selectedDate = DateTime.parse(value);
  final now = DateTime.now();
  if (selectedDate.isBefore(now)) {
    return 'Please choose a date in the future';
  }
  return null;
}
