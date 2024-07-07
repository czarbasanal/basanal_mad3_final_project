import 'package:basanal_mad3_final_project/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../models/journal_entry.dart';

class FirestoreService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _journalEntriesCollection =
      FirebaseFirestore.instance.collection('journal_entries');

  static void initialize() {
    GetIt.instance.registerSingleton<FirestoreService>(FirestoreService());
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Failed to create user');
    }
  }

  Future<UserModel> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data, doc.id);
      }
      throw Exception('User not found');
    } catch (e) {
      print('Error fetching user: $e');
      throw Exception('Failed to fetch user');
    }
  }

  Future<void> updateUser(UserModel user) async {
    await _usersCollection.doc(user.id).update(user.toMap());
  }

  Future<List<JournalEntry>> getJournalEntriesByUserId(String userId) async {
    final snapshot = await _journalEntriesCollection
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) =>
            JournalEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addJournalEntry(JournalEntry entry) async {
    final docRef = _journalEntriesCollection.doc();
    entry.id = docRef.id;
    await docRef.set(entry.toMap());
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    await _journalEntriesCollection.doc(entry.id).update(entry.toMap());
  }

  Future<JournalEntry> getJournalEntryById(String id) async {
    final doc = await _journalEntriesCollection.doc(id).get();
    if (doc.exists) {
      return JournalEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } else {
      throw Exception("Journal Entry not found");
    }
  }
}
