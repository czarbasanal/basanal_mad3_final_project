import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/journal_entry.dart';
import '../widgets/entry_form.dart';

class EntryScreen extends StatelessWidget {
  final String? entryId;

  EntryScreen({this.entryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entryId == null ? 'New Entry' : 'Edit Entry'),
      ),
      body: entryId == null
          ? EntryForm()
          : FutureBuilder<JournalEntry>(
              future: FirestoreService().getJournalEntryById(entryId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: Text('Entry not found'));
                }
                final entry = snapshot.data!;
                return EntryForm(entry: entry);
              },
            ),
    );
  }
}
