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

User? getCurrentUser() {
  final User? user = FirebaseAuth.instance.currentUser;
  return user;
}

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
                return const NewReservationDialog();
              },
            );
          },
        ),
        body: StreamBuilder<List<Reservation>>(
          stream: Reservation.readReservations(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final reservations = snapshot.data!
                  .where((reservation) => reservation.userId == currentUserId)
                  .toList();

              reservations.sort((a, b) => a.date.compareTo(b.date));

              return ListView.separated(
                itemBuilder: (context, index) =>
                    buildClass(reservations.toList()[index]),
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                  height: 1.0,
                ),
                itemCount: reservations.length,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  Widget buildClass(Reservation classObj) {
    return ReservationWidget(
      userId: currentUserId,
      equipmentReserved: classObj.equipmentReserved,
      date: classObj.date.toString(),
      timeSlot: classObj.timeSlot,
      notes: classObj.notes,
    );
  }
}
