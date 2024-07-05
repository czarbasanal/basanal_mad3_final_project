import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../dialogs/waiting_dialog.dart';
import '../services/firestore_service.dart';
import '../models/journal_entry.dart';
import '../routing/router.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  static const route = '/home';
  static const name = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Journal'),
      ),
      body: GoogleMap(
          initialCameraPosition: CameraPosition(
        target: LatLng(0, 0),
        zoom: 2,
      )),
      // body: FutureBuilder<List<JournalEntry>>(
      //   future: _loadJournalEntries(context),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const SizedBox.shrink();
      //     }
      //     if (snapshot.hasError) {
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     }
      //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
      //       return Center(child: Text('No journal entries found'));
      //     }
      //     final entries = snapshot.data!;
      //     return GoogleMap(
      //       initialCameraPosition: CameraPosition(
      //         target: LatLng(0, 0),
      //         zoom: 2,
      //       ),
      //       markers: entries.map((entry) {
      //         return Marker(
      //           markerId: MarkerId(entry.id),
      //           position:
      //               LatLng(entry.location.latitude, entry.location.longitude),
      //           infoWindow:
      //               InfoWindow(title: entry.title, snippet: entry.content),
      //           onTap: () {
      //             GlobalRouter.I.router.go('/entry/${entry.id}');
      //           },
      //         );
      //       }).toSet(),
      //     );
      //   },
      // ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GlobalRouter.I.router.go('/entry/new');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<JournalEntry>> _loadJournalEntries(BuildContext context) async {
    final userId = AuthController.I.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return [];
    }
    return await WaitingDialog.show(
          context,
          future: FirestoreService().getJournalEntriesByUserId(userId),
          prompt: 'Loading journal entries...',
          color: Colors.white,
        ) ??
        [];
  }
}
