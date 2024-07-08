import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../models/user.dart';
import '../models/journal_entry.dart';

class FirestoreService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _journalEntriesCollection =
      FirebaseFirestore.instance.collection('journal_entries');

  static FirestoreService get instance => GetIt.instance<FirestoreService>();

  static void initialize() {
    GetIt.instance.registerSingleton<FirestoreService>(FirestoreService());
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<UserModel> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  Future<List<JournalEntry>> getJournalEntriesByUserId(String userId) async {
    try {
      final snapshot = await _journalEntriesCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs
          .map((doc) =>
              JournalEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching journal entries: $e');
    }
  }

  Future<void> addJournalEntry(JournalEntry entry) async {
    try {
      final docRef = _journalEntriesCollection.doc();
      entry.id = docRef.id;
      await docRef.set(entry.toMap());
    } catch (e) {
      throw Exception('Error adding journal entry: $e');
    }
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    try {
      await _journalEntriesCollection.doc(entry.id).update(entry.toMap());
    } catch (e) {
      throw Exception('Error updating journal entry: $e');
    }
  }

  Future<JournalEntry> getJournalEntryById(String id) async {
    try {
      final doc = await _journalEntriesCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return JournalEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        throw Exception("Journal Entry not found");
      }
    } catch (e) {
      throw Exception('Error fetching journal entry: $e');
    }
  }

  Future<void> deleteJournalEntry(String id) async {
    try {
      await _journalEntriesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting journal entry: $e');
    }
  }
}
