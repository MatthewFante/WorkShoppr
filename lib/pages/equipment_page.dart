import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/new_reservation_dialog.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  _EquipmentPageState createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  @override
  Widget build(BuildContext context) {
    User? getCurrentUser() {
      final User? user = FirebaseAuth.instance.currentUser;
      return user;
    }

    final currentUserId = getCurrentUser()?.uid ?? 'Unknown';

    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('reservations')
              .where('userId', isEqualTo: currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final reservations = snapshot.data!.docs;

            if (reservations.isEmpty) {
              return const Center(
                child:
                    Text('No reservations yet', style: TextStyle(fontSize: 24)),
              );
            }

            return ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];

                return ListTile(
                  title: Text(reservation['equipmentReserved']),
                  subtitle: Text(
                      reservation['date'] + ' from ' + reservation['timeSlot']),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('reservations')
                          .doc(reservation.id)
                          .delete();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
