import 'package:basanal_mad3_final_project/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';

class FirestoreService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _journalEntriesCollection =
      FirebaseFirestore.instance.collection('journal_entries');

  Future<UserModel> getUserById(String id) async {
    final doc = await _usersCollection.doc(id).get();
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> addUser(UserModel user) async {
    final doc = await _usersCollection.doc(user.id).get();
    if (!doc.exists) {
      await _usersCollection.doc(user.id).set(user.toMap());
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

  Stream<UserModel> listenToUser(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(
            snapshot.data() as Map<String, dynamic>, snapshot.id);
      } else {
        throw Exception("User not found");
      }
    });
  }
}
