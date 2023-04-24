// Matthew Fante
// INFO-C342: Mobile Application Development
// Spring 2023 Final Project

// this class describes the reservations page which displays all reservations for the current user
// and allows the user to create new reservations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workshoppr/models/reservation.dart';
import 'package:workshoppr/widgets/new_reservation_dialog.dart';
import 'package:workshoppr/widgets/reservation_widget.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  _EquipmentPageState createState() => _EquipmentPageState();
}

// get the current user
User? getCurrentUser() {
  final User? user = FirebaseAuth.instance.currentUser;
  return user;
}

// get the current user id
final currentUserId = getCurrentUser()?.uid ?? 'Unknown';

class _EquipmentPageState extends State<EquipmentPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: const Text('Reserve'),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xff990000),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // show the new reservation dialog
                return const NewReservationDialog();
              },
            );
          },
        ),
        body: StreamBuilder<List<Reservation>>(
          stream: Reservation.readReservations(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // if there is an error, display an error message
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              // filter out reservations that are not for the current user or have already happened
              final reservations = snapshot.data!
                  .where((reservation) => reservation.userId == currentUserId)
                  .where((reservation) => dateFromString(reservation.date)
                      .isAfter(DateTime.now().subtract(Duration(days: 1))))
                  .toList();

              // sort the reservations by date
              reservations.sort((a, b) => a.date.compareTo(b.date));

              // display the reservations in a list view with a divider between each reservation
              return ListView.separated(
                itemBuilder: (context, index) =>
                    buildReservation(reservations.toList()[index]),
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                  height: 1.0,
                ),
                itemCount: reservations.length,
              );
            } else {
              // if there is no data, display a loading indicator
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  // build a reservation widget from a reservation object
  Widget buildReservation(Reservation classObj) {
    return ReservationWidget(
      userId: currentUserId,
      equipmentReserved: classObj.equipmentReserved,
      date: classObj.date.toString(),
      timeSlot: classObj.timeSlot,
      notes: classObj.notes,
    );
  }
}

DateTime dateFromString(String dateString) {
  List<String> dateComponents = dateString.split('/');
  int day = int.parse(dateComponents[1]);
  int month = int.parse(dateComponents[0]);
  int year = int.parse(dateComponents[2]);
  DateTime dateTime = DateTime(year, month, day);

  return dateTime;
}
