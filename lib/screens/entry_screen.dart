import 'package:basanal_mad3_final_project/routing/router.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/journal_entry.dart';
import '../widgets/entry_form.dart';
import '../dialogs/waiting_dialog.dart';

class EntryScreen extends StatelessWidget {
  final String? entryId;

  EntryScreen({this.entryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
          onPressed: () {
            GlobalRouter.I.router.pop();
          },
        ),
        title: Text(
          entryId == null ? 'Add New Note' : 'Edit Note',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: entryId == null
          ? EntryForm()
          : FutureBuilder<JournalEntry>(
              future: FirestoreService().getJournalEntryById(entryId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const WaitingDialog(
                    prompt: "Loading entry...",
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('Entry not found'));
                }
                final entry = snapshot.data!;
                return EntryForm(entry: entry);
              },
            ),
    );
  }
}
