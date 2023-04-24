// Matthew Fante
// INFO-C342: Mobile Application Development
// Spring 2023 Final Project

// this widget is used to display a 'create reservation' dialog

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewReservationDialog extends StatefulWidget {
  const NewReservationDialog({Key? key}) : super(key: key);

  @override
  _NewReservationDialogState createState() => _NewReservationDialogState();
}

class _NewReservationDialogState extends State<NewReservationDialog> {
  // define the date format
  final dateFormat = DateFormat('MM/dd/yyyy');
  final _formKey = GlobalKey<FormState>();

  // create controllers and variables for the form fields
  final _notesController = TextEditingController();
  var _selectedEquipment = '';
  var _selectedTimeSlot = '';

  // set the default date to tomorrow
  String _selectedDate = DateTime.now().add(const Duration(days: 1)).toString();

  // create lists for the dropdown menus
  List<String> _availableEquipment = [];
  List<String> _availableTimeSlots = [];

  Future<List<String>> getTimeslots() async {
    // get the available timeslots from the database
    List<String> timeslots = [];
    List<String> reservedTimeslots = [];

    // all timeslots defined in 'timeslots' collection
    QuerySnapshot snapshot1 =
        await FirebaseFirestore.instance.collection('timeslots').get();

    // all timeslots reserved in 'reservations' collection for the selected date and equipment
    final snapshot2 = await FirebaseFirestore.instance
        .collection('reservations')
        .where('equipmentReserved', isEqualTo: _selectedEquipment)
        .where('date',
            isEqualTo: dateFormat.format(DateTime.parse(_selectedDate)))
        .get();

    // add all timeslots to the list
    for (var doc in snapshot1.docs) {
      timeslots.add(doc['slot']);
    }

    // add all reserved timeslots to the list
    for (var doc in snapshot2.docs) {
      reservedTimeslots.add(doc['timeSlot']);
    }

    // remove all reserved timeslots from the list of available timeslots
    timeslots.removeWhere((element) => reservedTimeslots.contains(element));

    // sort the list
    timeslots.sort();
    return timeslots;
  }

  @override
  void dispose() {
    // dispose of the controllers
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // get the available equipment and timeslots
    getTimeslots().then((timeslots) {
      setState(() {
        _availableTimeSlots = timeslots;
        _selectedTimeSlot = _availableTimeSlots[0];
      });
    });

    getEquipmentList().listen((equipment) {
      setState(() {
        _availableEquipment = equipment;
        _selectedEquipment = _availableEquipment[0];
      });
    });

    // set the default date to tomorrow
    setState(() {
      _selectedDate = DateTime.now().add(const Duration(days: 1)).toString();
    });
  }

  Stream<List<String>> getEquipmentList() {
    // get the available equipment from the database
    return FirebaseFirestore.instance.collection('equipment').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => doc['name'].toString()).toList()
              ..sort());
  }

  @override
  Widget build(BuildContext context) {
    User? getCurrentUser() {
      // get the current user
      final User? user = FirebaseAuth.instance.currentUser;
      return user;
    }

    // get the current user's id
    final currentUserId = getCurrentUser()?.uid ?? 'Unknown';

    Future<bool> checkForConflictingReservationsEquipment() async {
      // check for conflicting reservations for the selected equipment and date
      final snapshot1 = await FirebaseFirestore.instance
          .collection('reservations')
          .where('equipmentReserved', isEqualTo: _selectedEquipment)
          .where('date',
              isEqualTo: dateFormat.format(DateTime.parse(_selectedDate)))
          .where('timeSlot', isEqualTo: _selectedTimeSlot)
          .get();

      if (snapshot1.docs.isNotEmpty) {
        // Conflicting reservation found
        return true;
      } else {
        // No conflicting reservation found
        return false;
      }
    }

    Future<bool> checkForConflictingReservationsUser() async {
      // check for conflicting reservations for the selected user and date
      final snapshot1 = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userId', isEqualTo: currentUserId)
          .where('date',
              isEqualTo: dateFormat.format(DateTime.parse(_selectedDate)))
          .where('timeSlot', isEqualTo: _selectedTimeSlot)
          .get();

      if (snapshot1.docs.isNotEmpty) {
        // Conflicting reservation found
        return true;
      } else {
        // No conflicting reservation found
        return false;
      }
    }

    return AlertDialog(
      title: const Text('Request a reservation'),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField(
                      value: _selectedEquipment,
                      onChanged: (newValue) {
                        setState(() {
                          // update the selected equipment
                          _selectedEquipment = newValue as String;
                        });

                        getTimeslots().then((timeslots) {
                          setState(() {
                            // update the available timeslots and selected timeslot based on availability
                            _availableTimeSlots = timeslots;
                            _selectedTimeSlot = _availableTimeSlots[0];
                          });
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Equipment Reserved',
                      ),
                      items: _availableEquipment.map((equipment) {
                        return DropdownMenuItem(
                          value: equipment,
                          child: Text(equipment),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // display the selected date
                          _selectedDate != ''
                              ? dateFormat.format(DateTime.parse(_selectedDate))
                              : 'Select a date',
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
                                      setState(() {
                                        _selectedDate = date.toString();
                                      });

                                      getTimeslots().then((timeslots) {
                                        // update the available timeslots and selected timeslot based on availability
                                        setState(() {
                                          _availableTimeSlots = timeslots;
                                          _selectedTimeSlot =
                                              _availableTimeSlots[0];
                                        });
                                      });
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField(
                      value: _selectedTimeSlot,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTimeSlot = newValue as String;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Time Slot',
                      ),
                      items: _availableTimeSlots.map((timeslot) {
                        return DropdownMenuItem(
                          value: timeslot,
                          child: Text(timeslot),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                      ),
                      validator: (value) {
                        // Notes are optional, so no validation needed
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: () async {
            // check for conflicting reservations for the selected equipment and date
            final equipmentHasConflictingReservations =
                await checkForConflictingReservationsEquipment();

            // check for conflicting reservations for the selected user and date
            final userHasConflictingReservations =
                await checkForConflictingReservationsUser();

            // Validate the form
            if (_formKey.currentState!.validate()) {
              // Prompt the user if the date they selected has passed
              if (DateTime.parse(_selectedDate).isBefore(DateTime.now())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select a date in the future')),
                );
                return;
              }

              // Alert the user if the selected equipment is already reserved for the selected date and timeslot
              if (equipmentHasConflictingReservations) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'That equipment is already reserved for that timeslot.')),
                );
                return;
              }

              // Alert the user if they already has a reservation for the selected date and timeslot
              if (userHasConflictingReservations) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('You already have a reservation at that time.')),
                );
                return;
              }

              // Create a new reservation document
              await FirebaseFirestore.instance.collection('reservations').add({
                'userId': currentUserId,
                'equipmentReserved': _selectedEquipment,
                'date': dateFormat.format(DateTime.parse(_selectedDate)),
                'timeSlot': _selectedTimeSlot,
                'notes': _notesController.text,
              });

              // Show a snackbar with a message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('$_selectedEquipment Reservation successful!')),
              );
              // Close the dialog
              Navigator.pop(context);
            }
            setState(() {
              // Reset the form
              _selectedEquipment = _availableEquipment[0];
              _selectedDate =
                  DateTime.now().add(const Duration(days: 1)).toString();
              _selectedTimeSlot = _availableTimeSlots[0];
              _notesController.text = '';
            });
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

String? validateDate(String? value) {
  // Check if the date is empty
  if (value == null || value.isEmpty) {
    return 'Please choose a date';
  }
  final selectedDate = DateTime.parse(value);
  final now = DateTime.now();
  if (selectedDate.isBefore(now)) {
    // Check if the date is in the past
    return 'Please choose a date in the future';
  }
  return null;
}
