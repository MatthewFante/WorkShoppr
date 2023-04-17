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
  final dateFormat = DateFormat('MM/dd/yyyy');
  final _formKey = GlobalKey<FormState>();

  final _notesController = TextEditingController();
  var _selectedEquipment = '';
  var _selectedTimeSlot = '';
  String _selectedDate = DateTime.now().add(const Duration(days: 1)).toString();

  List<String> _availableEquipment = [];
  List<String> _availableTimeSlots = [];

  Future<List<String>> getTimeslots() async {
    List<String> timeslots = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('timeslots').get();
    for (var doc in snapshot.docs) {
      timeslots.add(doc['slot']);
    }
    return timeslots;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

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

    setState(() {
      _selectedDate = DateTime.now().add(const Duration(days: 1)).toString();
    });
  }

  Stream<List<String>> getEquipmentList() {
    return FirebaseFirestore.instance.collection('equipment').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => doc['name'].toString()).toList()
              ..sort());
  }

  @override
  Widget build(BuildContext context) {
    User? getCurrentUser() {
      final User? user = FirebaseAuth.instance.currentUser;
      return user;
    }

    final currentUserId = getCurrentUser()?.uid ?? 'Unknown';

    Stream<List<DocumentSnapshot>> getReservations() {
      return FirebaseFirestore.instance
          .collection('reservations')
          .where('date', isEqualTo: _selectedDate)
          .where('timeSlot', isEqualTo: _selectedTimeSlot)
          .where('equipment', isEqualTo: _selectedEquipment)
          .snapshots()
          .map((snapshot) => snapshot.docs);
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
                          _selectedEquipment = newValue as String;
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
                                      // Set the text field to the selected date.
                                      setState(() {
                                        _selectedDate = date.toString();
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
            if (_formKey.currentState!.validate()) {
              if (DateTime.parse(_selectedDate).isBefore(DateTime.now())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select a date in the future')),
                );
                final reservations = await getReservations().first;
                final conflictingReservations = reservations.where((doc) =>
                    doc['date'] == _selectedDate &&
                    doc['timeslot'] == _selectedTimeSlot);

                print(conflictingReservations.toString());

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

              Navigator.pop(context);
            }
            setState(() {
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
